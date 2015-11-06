import Quick
import Nimble
import Clappr

class BaseObjectTests: QuickSpec {
    
    override func spec() {
        describe("BaseObject") {
            
            var baseObject: BaseObject!
            var callbackWasCalled: Bool!
            
            let eventName = "some-event"
            let callback: EventCallback = { userInfo in
                callbackWasCalled = true
            }
            
            beforeEach {
                baseObject = BaseObject()
                callbackWasCalled = false
            }
            
            describe("on") {
                it("Callback should be called on event trigger") {
                    baseObject.on(eventName, callback: callback)
                    baseObject.trigger(eventName)
                    
                    expect(callbackWasCalled) == true
                }
                
                it("Callback should receive userInfo on trigger with params") {
                    var value = "Not Expected"
                    baseObject.on(eventName) { userInfo in
                        value = userInfo?["new_value"] as! String
                    }
                    
                    baseObject.trigger(eventName, userInfo: ["new_value": "Expected"])
                    
                    expect(value) == "Expected"
                }
                
                it("Callback should be called for every callback registered") {
                    baseObject.on(eventName, callback: callback)
                    
                    var secondCallbackWasCalled = false
                    baseObject.on(eventName) { userInfo in
                        secondCallbackWasCalled = true
                    }
                    
                    baseObject.trigger(eventName)
                    
                    expect(callbackWasCalled) == true
                    expect(secondCallbackWasCalled) == true
                }
                
                it("Callback should not be called for another event trigger") {
                    baseObject.on(eventName, callback: callback)
                    
                    baseObject.trigger("another-event")
                    
                    expect(callbackWasCalled) == false
                }
                
                it("Callback should not be called for another context object") {
                    let anotherObject = BaseObject()
                    
                    baseObject.on(eventName, callback: callback)
                    
                    anotherObject.trigger(eventName);
                    
                    expect(callbackWasCalled) == false
                }
                
                it("Callback should not be called when stop listening is called") {
                    baseObject.on(eventName, callback: callback)
                    baseObject.on("another-event", callback: callback)
                    baseObject.stopListening()
                    
                    expect(callbackWasCalled) == false
                }
            }
            
            describe("once") {
                it("Callback should be called on event trigger") {
                    baseObject.once(eventName, callback: callback)
                    baseObject.trigger(eventName)
                    
                    expect(callbackWasCalled) == true
                }
                
                it("Callback should not be called twice") {
                    baseObject.once(eventName, callback: callback)
                    
                    baseObject.trigger(eventName)
                    callbackWasCalled = false
                    baseObject.trigger(eventName)
                    
                    expect(callbackWasCalled) == false
                }
            }
            
            describe("listenTo") {
                it("Should fire callback for an event on a given context object") {
                    let contextObject = BaseObject()
                    
                    baseObject.listenTo(contextObject, eventName: eventName, callback: callback)
                    baseObject.trigger(eventName)
                    
                    expect(callbackWasCalled) == true
                }
            }
            
            describe("off") {
                it("Callback should not be called if removed") {
                    baseObject.on(eventName, callback: callback)
                    baseObject.off(eventName, callback: callback)
                    baseObject.trigger(eventName)
                    
                    expect(callbackWasCalled) == false
                    
                }
                it("Callback should not be called if removed, but the others should") {
                    var anotherCallbackWasCalled = false
                    let anotherCallback: EventCallback = { userInfo in
                        anotherCallbackWasCalled = true
                    }
                    
                    baseObject.on(eventName, callback: callback)
                    baseObject.on(eventName, callback: anotherCallback)
                    
                    baseObject.off(eventName, callback: callback)
                    baseObject.trigger(eventName)
                    
                    expect(callbackWasCalled) == false
                    expect(anotherCallbackWasCalled) == true
                }
            }
        }
    }
}