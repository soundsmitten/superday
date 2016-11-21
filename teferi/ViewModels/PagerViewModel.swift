import RxSwift
import Foundation

class PagerViewModel
{
    //MARK: Fields
    private let settingsService : SettingsService
    private let dateVariable = Variable(Date())
    
    init(settingsService: SettingsService)
    {
        self.settingsService = settingsService
        self.dateObservable = self.dateVariable.asObservable()
    }
    
    //MARK: Properties
    var date : Date
    {
        get { return self.dateVariable.value }
        set(value) { self.dateVariable.value = value }
    }
    
    let dateObservable : Observable<Date>
    
    //Methods
    func canScroll(toDate date: Date) -> Bool
    {
        let minDate = self.settingsService.installDate!.ignoreTimeComponents()
        let maxDate = Date().ignoreTimeComponents()
        let dateWithNoTime = date.ignoreTimeComponents()
        
        return dateWithNoTime >= minDate && dateWithNoTime <= maxDate
    }
}
