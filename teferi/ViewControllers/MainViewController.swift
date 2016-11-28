import UIKit
import RxSwift
import MessageUI
import CoreMotion
import CoreGraphics
import QuartzCore
import CoreLocation
import SnapKit

class MainViewController : UIViewController, MFMailComposeViewControllerDelegate
{
    // MARK: Fields
    private var isFirstUse = false
    private let animationDuration = 0.08
    
    private var disposeBag : DisposeBag? = DisposeBag()
    private var gestureRecognizer : UIGestureRecognizer!
    private lazy var viewModel : MainViewModel =
    {
        return MainViewModel(metricsService: self.metricsService,
                             timeSlotService: self.timeSlotService,
                             settingsService: self.settingsService,
                             editStateService: self.editStateService,
                             feedbackService: self.feedbackService)
    }()
    
    private var pagerViewController : PagerViewController { return self.childViewControllers.last as! PagerViewController }
    
    //Dependencies
    private var metricsService : MetricsService!
    private var appStateService : AppStateService!
    private var locationService : LocationService!
    private var settingsService : SettingsService!
    private var timeSlotService : TimeSlotService!
    private var editStateService : EditStateService!
    private var feedbackService: FeedbackService!
    
    private var editView : EditTimeSlotView!
    private var addButton : AddTimeSlotView!
    private var permissionView : PermissionView?
    private var launchAnim : LaunchAnimationView!
    
    @IBOutlet private weak var icon : UIImageView!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var calendarButton : UIButton!
    @IBOutlet private weak var contactButton: UIButton!
    
    func inject(_ metricsService: MetricsService,
                _ appStateService: AppStateService,
                _ locationService: LocationService,
                _ settingsService: SettingsService,
                _ timeSlotService: TimeSlotService,
                _ editStateService: EditStateService,
                _ feedbackService: FeedbackService) -> MainViewController
    {
        self.metricsService = metricsService
        self.appStateService = appStateService
        self.locationService = locationService
        self.settingsService = settingsService
        self.timeSlotService = timeSlotService
        self.editStateService = editStateService
        self.feedbackService = feedbackService
        
        return self
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Inject PagerViewController's dependencies
        self.pagerViewController.inject(self.metricsService,
                                        self.appStateService,
                                        self.settingsService,
                                        self.timeSlotService,
                                        self.editStateService)        
        
        //Add fade overlay at bottom of timeline
        let bottomFadeStartColor = UIColor.white.withAlphaComponent(1.0)
        let bottomFadeEndColor = UIColor.white.withAlphaComponent(0.0)
        let bottomFadeOverlay = self.fadeOverlay(startColor: bottomFadeStartColor, endColor: bottomFadeEndColor)
        let fadeView = AutoResizingLayerView(layer: bottomFadeOverlay)
        self.view.addSubview(fadeView)
        fadeView.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.snp.bottom)
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.height.equalTo(100)
        }
        
        //Add button
        self.addButton = (Bundle.main.loadNibNamed("AddTimeSlotView", owner: self, options: nil)?.first) as? AddTimeSlotView
        
        //Edit View
        self.editView = EditTimeSlotView(frame: self.view.frame, editEndedCallback: self.viewModel.updateTimeSlot)
        self.view.addSubview(self.editView)
        
        if self.isFirstUse
        {
            //Sets the first TimeSlot's category to leisure
            let timeSlot = TimeSlot(category: .leisure)
            self.timeSlotService.add(timeSlot: timeSlot)
        }
        else
        {
            self.launchAnim = LaunchAnimationView(frame: view.frame)
            self.view.addSubview(launchAnim)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.startLaunchAnimation()
        
        self.calendarButton.setTitle(viewModel.calendarDay, for: .normal)
        
        //Refresh Dispose bag, if needed
        self.disposeBag = self.disposeBag ?? DisposeBag()
        
        self.gestureRecognizer = ClosureGestureRecognizer(withClosure: { self.editStateService.notifyEditingEnded() })
        
        //Edit state
        self.editStateService
            .isEditingObservable
            .subscribe(onNext: self.onEditChanged)
            .addDisposableTo(disposeBag!)
        
        self.editStateService
            .beganEditingObservable
            .subscribe(onNext: self.editView.onEditBegan)
            .addDisposableTo(disposeBag!)
        
        //Category creation
        self.addButton
            .categoryObservable
            .subscribe(onNext: self.viewModel.addNewSlot)
            .addDisposableTo(disposeBag!)
        
        //Date updates for title label
        self.pagerViewController
            .dateObservable
            .subscribe(onNext: self.onDateChanged)
            .addDisposableTo(disposeBag!)
        
        self.editView.addGestureRecognizer(self.gestureRecognizer)
        
        self.appStateService
            .appStateObservable
            .subscribe(onNext: self.onAppStateChanged)
            .addDisposableTo(disposeBag!)
        
        //Add button must be added like this due to .xib/.storyboard restrictions
        self.view.insertSubview(self.addButton, belowSubview: self.editView)
        self.addButton.snp.makeConstraints { make in
            make.height.equalTo(320)
            make.left.equalTo(self.view.snp.left)
            make.width.equalTo(self.view.snp.width)
            make.bottom.equalTo(self.view.snp.bottom)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.disposeBag = nil
        self.editView.removeGestureRecognizer(self.gestureRecognizer)
        super.viewWillDisappear(animated)
    }
    
    // MARK: Actions
    @IBAction func onCalendarTouchUpInside()
    {
        let today = Date().ignoreTimeComponents()
        
        guard self.viewModel.currentDate.ignoreTimeComponents() != today else { return }
        
        self.pagerViewController.setViewControllers(
            [ TimelineViewController(date: today,
                                     metricsService: self.metricsService,
                                     timeSlotService: self.timeSlotService,
                                     editStateService: self.editStateService) ],
            direction: .forward,
            animated: true,
            completion: nil)
        
        self.onDateChanged(date: today)
    }
    
    @IBAction func onContactTouchUpInside()
    {
        self.feedbackService.composeFeedback(parentViewController: self) {
            self.pagerViewController.feedbackUIClosing = true
        }
    }
    
    // MARK: Methods
    func setIsFirstUse()
    {
        self.isFirstUse = true
    }
    
    private func startLaunchAnimation()
    {
        guard self.launchAnim != nil else { return }
        
        //Small delay to give launch screen time to fade away
        Timer.schedule(withDelay: 0.1) { _ in
            self.launchAnim?.animate(onCompleted:
            {
                self.launchAnim!.removeFromSuperview()
                self.launchAnim = nil
            })
        }
    }
    
    private func onAppStateChanged(appState: AppState)
    {
        if appState == .active
        {
            if self.viewModel.shouldShowLocationPermissionOverlay
            {
                guard permissionView == nil else { return }
                
                let isFirstTimeUser = !self.settingsService.canIgnoreLocationPermission
                let view = Bundle.main.loadNibNamed("PermissionView", owner: self, options: nil)!.first as! PermissionView!
                
                self.permissionView = view!.inject(self.view.frame, self.settingsService, isFirstTimeUser: isFirstTimeUser)
                
                if self.launchAnim != nil
                {
                    self.view.insertSubview(self.permissionView!, belowSubview: self.launchAnim)
                }
                else
                {
                    self.view.addSubview(self.permissionView!)
                }
            }
            else
            {
                guard let view = permissionView else { return }
                
                view.fadeView()
                self.permissionView = nil
                self.settingsService.setAllowedLocationPermission()
            }
        }
    }
    
    private func onDateChanged(date: Date)
    {
        self.viewModel.currentDate = date
        self.titleLabel.text = viewModel.title
        
        let today = Date().ignoreTimeComponents()
        let isToday = today == date.ignoreTimeComponents()
        let alpha = CGFloat(isToday ? 1 : 0)
        
        UIView.animate(withDuration: 0.3)
        {
            self.addButton.alpha = alpha
        }
        
        self.addButton.close()
        self.addButton.isUserInteractionEnabled = isToday
    }
    
    private func onEditChanged(_ isEditing: Bool)
    {
        //Close add menu
        self.addButton.close()
        
        //Grey out views
        self.editView.isEditing = isEditing
    }
    
    //Configure overlay
    private func fadeOverlay(startColor: UIColor, endColor: UIColor) -> CAGradientLayer
    {
        let fadeOverlay = CAGradientLayer()
        fadeOverlay.colors = [startColor.cgColor, endColor.cgColor]
        fadeOverlay.locations = [0.1]
        fadeOverlay.startPoint = CGPoint(x: 0.0, y: 1.0)
        fadeOverlay.endPoint = CGPoint(x: 0.0, y: 0.0)
        return fadeOverlay
    }
}
