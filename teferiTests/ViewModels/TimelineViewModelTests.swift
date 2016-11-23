import Foundation
import XCTest
import RxSwift
import Nimble
@testable import teferi

class TimelineViewModelTests : XCTestCase
{
    private var disposable : Disposable? = nil
    private var viewModel : TimelineViewModel!
    private var mockMetricsService : MockMetricsService!
    private var mockTimeSlotService : MockTimeSlotService!

    override func setUp()
    {
        self.mockMetricsService = MockMetricsService()
        self.mockTimeSlotService = MockTimeSlotService()
        self.viewModel = TimelineViewModel(date: Date(),
                                           metricsService: self.mockMetricsService,
                                           timeSlotService: self.mockTimeSlotService)
    }
    
    override func tearDown()
    {
        self.disposable?.dispose()
    }
    
    func testOnlyViewModelsForTheCurrentDaySubscribeForTimeSlotUpdates()
    {
        expect(self.mockTimeSlotService.didSubscribe).to(beTrue())
    }
    
    func testIfThereAreNoTimeSlotsForTheCurrentDayTheViewModelCreatesOne()
    {
        expect(self.viewModel.timeSlots.count).to(equal(1))
    }
    
    func testViewModelsForTheOlderDaysDoNotSubscribeForTimeSlotUpdates()
    {
        let newMockTimeSlotService = MockTimeSlotService()
        _ = TimelineViewModel(date: Date().yesterday,
                              metricsService: self.mockMetricsService,
                              timeSlotService: newMockTimeSlotService)
        
        expect(newMockTimeSlotService.didSubscribe).to(beFalse())
    }
    
    func testTheNewlyAddedSlotHasNoEndTime()
    {
        let timeSlot = TimeSlot(category: .work)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        let lastSlot = viewModel.timeSlots.last!
        
        expect(lastSlot.endTime).to(beNil())
    }
    
    func testTheAddNewSlotsMethodEndsThePreviousTimeSlot()
    {
        let timeSlot = TimeSlot(category: .work)
        self.mockTimeSlotService.add(timeSlot: timeSlot)
        let firstSlot = viewModel.timeSlots.first!
        
        let otherTimeSlot = TimeSlot(category: .work)
        self.mockTimeSlotService.add(timeSlot: otherTimeSlot)
        
        expect(firstSlot.endTime).toNot(beNil())
    }
}
