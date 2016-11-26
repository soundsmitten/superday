import XCTest
import Nimble
@testable import teferi

class PagerViewControllerTests : XCTestCase
{
    private var metricsService : MetricsService!
    private var appStateService : AppStateService!
    private var settingsService : SettingsService!
    private var timeSlotService : TimeSlotService!
    private var editStateService : EditStateService!
    private var pagerViewController : PagerViewController!
    
    override func setUp()
    {
        super.setUp()
 
        self.metricsService = MockMetricsService()
        self.settingsService = MockSettingsService()
        self.appStateService = MockAppStateService()
        self.timeSlotService = MockTimeSlotService()
        self.editStateService = MockEditStateService()
        
        self.pagerViewController = PagerViewController(coder: NSCoder())!
        self.pagerViewController.inject(self.metricsService,
                                        self.appStateService,
                                        self.settingsService,
                                        self.timeSlotService,
                                        self.editStateService)
        
        self.pagerViewController.loadViewIfNeeded()
        UIApplication.shared.keyWindow!.rootViewController = self.pagerViewController
    }
    
    override func tearDown()
    {
        self.pagerViewController.viewWillDisappear(false)
        self.pagerViewController = nil
    }
    
    func testScrollingIsDisabledWhenEnteringEditMode()
    {
        self.editStateService.notifyEditingBegan(point: CGPoint(), timeSlot: TimeSlot());
        
        let scrollViews =
            self.pagerViewController
                .view
                .subviews
                .flatMap { v in v as? UIScrollView }
        
        expect(scrollViews).to(allPass { !$0!.isScrollEnabled  })
    }
    
    func testScrollingIsEnabledWhenExitingEditMode()
    {
        self.editStateService.notifyEditingBegan(point: CGPoint(), timeSlot: TimeSlot());
        self.editStateService.notifyEditingEnded();
        
        let scrollViews =
            self.pagerViewController
                .view
                .subviews
                .flatMap { v in v as? UIScrollView }
        
        expect(scrollViews).to(allPass { $0!.isScrollEnabled  })
    }
    
    func testWhenTheAppGetsInactiveTheLastInactiveDateGetsSet()
    {
        self.settingsService.setLastInactiveDate(nil)
        self.appStateService.currentAppState = .inactive
        
        expect(self.settingsService.lastInactiveDate).toNot(beNil())
    }
    
    func testUiGetsRefreshedWhenTheAppGoesToForegroundTheDayAfterItWentToSleep()
    {
        self.pagerViewController.setViewControllers( [ UIViewController() ], direction: .forward, animated: false, completion: nil)
        
        let date = Date().add(days: -2)
        self.settingsService.setLastInactiveDate(date)
        self.appStateService.currentAppState = .active
        
        expect(self.pagerViewController.viewControllers!.first).to(beAnInstanceOf(TimelineViewController.self))
    }
    
    func testTheLastInactiveDateGetsResetWhenTheAppIsAwakeAndRefreshed()
    {
        let date = Date().add(days: -2)
        self.settingsService.setLastInactiveDate(date)
        self.appStateService.currentAppState = .active
        
        expect(self.settingsService.lastInactiveDate).to(beNil())
    }
    
    func testTheDateObservableNotifiesANewDateWhenTheUserScrollsToADifferentPage()
    {
        var didNotify = false
        
        _ = self.pagerViewController
                .dateObservable
                .subscribe(onNext: { _ in didNotify = true })
        
        self.pagerViewController.pageViewController(self.pagerViewController, didFinishAnimating: true, previousViewControllers: self.pagerViewController.viewControllers!, transitionCompleted: true)
        
        expect(didNotify).to(beTrue())
    }
    
    func testTheViewControllerDoesNotAllowScrollingAfterTheCurrentDate()
    {
        let nextViewController = self.scrollForward()
        
        expect(nextViewController).to(beNil())
    }
    
    func testTheViewControllerDoesNotAllowScrollingBeforeTheInstallDate()
    {
        self.settingsService.setInstallDate(Date())
        
        let previousViewController = self.scrollBack()
        
        expect(previousViewController).to(beNil())
    }
    
    func testTheViewControllerScrollsBackOneDayAtATime()
    {
        self.settingsService.setInstallDate(Date().add(days: -10))
        
        let previousViewController = self.scrollBack()!
        
        expect(previousViewController.date.ignoreTimeComponents()).to(equal(Date().yesterday.ignoreTimeComponents()))
    }
    
    func testTheViewControllerScrollsForwardOneDayAtATime()
    {
        self.settingsService.setInstallDate(Date().add(days: -10))
        
        var previous = self.scrollBack(from: nil)
        previous = self.scrollBack(from: previous)
        
        let nextViewController = self.scrollForward(from: previous)!
        
        expect(nextViewController.date.ignoreTimeComponents()).to(equal(Date().yesterday.ignoreTimeComponents()))
    }
    
    @discardableResult func scrollBack(from viewController: UIViewController? = nil) -> TimelineViewController?
    {
        let targetViewController = viewController ?? self.pagerViewController.viewControllers!.last!
        
        return self.pagerViewController
            .pageViewController(self.pagerViewController, viewControllerBefore: targetViewController) as? TimelineViewController
    }
    
    @discardableResult func scrollForward(from viewController: UIViewController? = nil) -> TimelineViewController?
    {
        let targetViewController = viewController ?? self.pagerViewController.viewControllers!.last!
        
        return self.pagerViewController.pageViewController(self.pagerViewController, viewControllerAfter: targetViewController) as? TimelineViewController
    }
}
