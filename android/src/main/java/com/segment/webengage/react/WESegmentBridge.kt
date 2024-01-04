

package com.segment.webengage.react

import android.content.Context
import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.segment.webengage.react.utils.WESegmentHelper


class WESegmentBridge(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    
    private val context: Context = reactContext.applicationContext

    override fun getName(): String = "WESegmentBridge"


    @ReactMethod
    fun create(payload: ReadableMap) {
        WESegmentHelper.getInstance().create(context,payload)
    }


    @ReactMethod
    fun trackEvent(event:String, payload: ReadableMap?) {
        WESegmentHelper.getInstance().trackEvent(event, payload)
    }

    @ReactMethod
    fun trackScreen(screenName:String, payload: ReadableMap?) {
        WESegmentHelper.getInstance().trackScreen(screenName, payload)
    }
  
    @ReactMethod
    fun logout() {
       WESegmentHelper.getInstance().logoutUser()
    }

    @ReactMethod
    fun identify(payload: ReadableMap){
        Log.e("TAG", "Android identify: " )
        WESegmentHelper.getInstance().identify(payload)
    }
}