package com.segment.webengage.react.utils

import android.app.Application
import android.content.Context
import android.util.Log
import com.facebook.react.bridge.ReadableMap
import com.webengage.sdk.android.Channel
import com.webengage.sdk.android.Logger
import com.webengage.sdk.android.UserProfile
import com.webengage.sdk.android.WebEngage
import com.webengage.sdk.android.WebEngageActivityLifeCycleCallbacks
import com.webengage.sdk.android.WebEngageConfig
import com.webengage.sdk.android.utils.Gender

import java.lang.Boolean
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.GregorianCalendar
import java.util.TimeZone
import kotlin.Any
import kotlin.Exception
import kotlin.Int
import kotlin.String
import kotlin.let
import kotlin.run
import kotlin.takeIf
import kotlin.toString


class WESegmentHelper {

    private val tag = javaClass.name
    private var webEngageConfig: WebEngageConfig? = null

    fun create(context: Context, payload: ReadableMap) {
        val map = WEAppUtils().recursivelyDeconstructReadableMap(payload)
        var licenseCode = map[LICENSE_CODE_KEY] as String?
        var overrideLC = ""

        WEAppUtils().getApplicationMetaData(context.applicationContext)?.run {
            if (containsKey("com.webengage.sdk.android.key")) {
                getString("com.webengage.sdk.android.key")?.let {
                    overrideLC = it
                }
            }
        }

        licenseCode = overrideLC.takeIf { it.isNotEmpty() } ?: licenseCode ?: run {
            Logger.i(
                tag,
                "Unable to initialize WebEngage through Segment Integration, Reason: license code is null"
            )
            return
        }

        Log.e(tag, "create: ${licenseCode} ${overrideLC} ${map}" )

        val mergedConfig = if (webEngageConfig != null) {
            webEngageConfig!!.currentState.setWebEngageKey(licenseCode).setDebugMode(true).build()
        } else {
            WebEngageConfig.Builder().setWebEngageKey(licenseCode).setDebugMode(true).build()
        }

        initWebEngage(context, mergedConfig)

        Logger.v(
            tag,
            "Started WebEngage SDK initialization through Segment Integration, license code: $licenseCode"
        )
    //    WebEngage.engage(context.applicationContext, mergedConfig)
    }

    companion object {
        private const val LICENSE_CODE_KEY = "licenseCode"

        private var instance: WESegmentHelper? = null

        @Synchronized
        fun getInstance(): WESegmentHelper {
            if (instance == null) {
                instance = WESegmentHelper()
            }
            return instance!!
        }
    }

    fun initWebEngage(context: Context,webEngageConfig: WebEngageConfig?){
        this.webEngageConfig = webEngageConfig
        (context as Application).registerActivityLifecycleCallbacks(
            WebEngageActivityLifeCycleCallbacks(
                context,
                webEngageConfig
            )
        )
    }

    fun trackEvent(event: String, payload: ReadableMap?) {
        val map = payload?.let { WEAppUtils().recursivelyDeconstructReadableMap(it) }
        WebEngage.get().analytics().track(event, map)
    }

    fun trackScreen(screenName: String, payload: ReadableMap?) {
        val map = payload?.let { WEAppUtils().recursivelyDeconstructReadableMap(it) }
        WebEngage.get().analytics().screenNavigated(screenName, map);
    }

    fun logoutUser() {
        WebEngage.get().user().logout()
    }

    fun identify(payload: ReadableMap){

        val identify = WEAppUtils().recursivelyDeconstructReadableMap(payload)

        val traits: HashMap<String, Any?> = identify["traits"] as HashMap<String, Any?>
        val userId = identify["userId"] as String?
        userId?.let {
            WebEngage.get().user().login(it)
            identify.remove("userId")
        }
        val userProfileBuilder: UserProfile.Builder = UserProfile.Builder()
        if(!traits.isEmpty()){

            if (traits[FIRST_NAME_KEY] == null && traits[LAST_NAME_KEY] == null) {
                val name = traits[NAME_KEY] as String?
                if (name != null) {
                    val components = name.split(" ".toRegex()).dropLastWhile { it.isEmpty() }
                        .toTypedArray()
                    userProfileBuilder.setFirstName(components[0])
                    if (components.size > 1) {
                        userProfileBuilder.setLastName(components[components.size - 1])
                    }
                    traits.remove(NAME_KEY)
                }
            }

            if (traits[FIRST_NAME_KEY] != null) {
                userProfileBuilder.setFirstName(traits[FIRST_NAME_KEY] as String?)
                traits.remove(FIRST_NAME_KEY)
            }
            if (traits[LAST_NAME_KEY] != null) {
                userProfileBuilder.setLastName(traits[LAST_NAME_KEY] as String?)
                traits.remove(LAST_NAME_KEY)
            }
            if (traits[INDUSTRY_KEY] != null) {
                userProfileBuilder.setCompany(traits[INDUSTRY_KEY] as String?)
                traits.remove(INDUSTRY_KEY)
            }
            if (traits[EMAIL_KEY] != null) {
                userProfileBuilder.setEmail(traits[EMAIL_KEY] as String?)
                traits.remove(EMAIL_KEY)
            }
            if (traits[GENDER_KEY] != null) {
                val gender = Gender.valueByString(traits[GENDER_KEY] as String?)
                userProfileBuilder.setGender(gender)
                traits.remove(GENDER_KEY)
            }
            if (traits[PHONE_KEY] != null) {
                userProfileBuilder.setPhoneNumber(traits[PHONE_KEY] as String?)
                traits.remove(PHONE_KEY)
            }

            if (traits[ADDRESS_KEY] != null && traits[ADDRESS_KEY] is Map<*, *>) {
                traits.putAll(traits[ADDRESS_KEY] as HashMap<String,Any>)
                traits.remove(ADDRESS_KEY)
            }

            if (traits[BIRTHDAY_KEY] != null) {
                                val birthDateObj = traits[BIRTHDAY_KEY]
                if (birthDateObj != null) {
                    var birthDate: Date? = null
                    try {
                        birthDate = toISO8601Date(birthDateObj as String?)
                    } catch (e: Exception) {
                        Log.e(javaClass.name, "identify: ${e.message}" )
                    }
                    if (birthDate != null) {
                        val gregorianCalendar: Calendar =
                            GregorianCalendar.getInstance(TimeZone.getTimeZone("UTC"))
                        gregorianCalendar.setTime(birthDate)
                        val year: Int = gregorianCalendar.get(Calendar.YEAR)
                        val month: Int = gregorianCalendar.get(Calendar.MONTH) + 1
                        val day: Int = gregorianCalendar.get(Calendar.DAY_OF_MONTH)
                        userProfileBuilder.setBirthDate(year, month, day)
                        traits.remove(BIRTHDAY_KEY)
                    }
                }
            }


        }

        val webengageOptions: Map<String, Any?> = identify["integrations"] as HashMap<String,Any?>
        if (webengageOptions != null) {
            if (webengageOptions[HASHED_EMAIL_KEY] != null) {
                userProfileBuilder.setHashedEmail(webengageOptions[HASHED_EMAIL_KEY] as String?)
            }
            if (webengageOptions[HASHED_PHONE_KEY] != null) {
                userProfileBuilder.setHashedPhoneNumber(webengageOptions[HASHED_PHONE_KEY] as String?)
            }
            if (webengageOptions[PUSH_OPT_IN_KEY] != null) {
                val pushOptIn = Boolean.valueOf(webengageOptions[PUSH_OPT_IN_KEY].toString())
                userProfileBuilder.setOptIn(Channel.PUSH, pushOptIn)
            }
            if (webengageOptions[SMS_OPT_IN_KEY] != null) {
                val smsOptIn = Boolean.valueOf(webengageOptions[SMS_OPT_IN_KEY].toString())
                userProfileBuilder.setOptIn(Channel.SMS, smsOptIn)
            }
            if (webengageOptions[EMAIL_OPT_IN_KEY] != null) {
                val emailOptIn = Boolean.valueOf(webengageOptions[EMAIL_OPT_IN_KEY].toString())
                userProfileBuilder.setOptIn(Channel.EMAIL, emailOptIn)
            }
            if (webengageOptions[WHATSAPP_OPT_IN_KEY] != null) {
                val whatsappOptIn =
                    Boolean.valueOf(webengageOptions[WHATSAPP_OPT_IN_KEY].toString())
                userProfileBuilder.setOptIn(Channel.WHATSAPP, whatsappOptIn)
            }
            if (webengageOptions[INAPP_OPT_IN_KEY] != null) {
                val inAppOptIn = Boolean.valueOf(webengageOptions[INAPP_OPT_IN_KEY].toString())
                userProfileBuilder.setOptIn(Channel.IN_APP, inAppOptIn)
            }
        }

        WebEngage.get().user().setUserProfile(userProfileBuilder.build())
        if (traits.isNotEmpty()) {
            WebEngage.get().user().setAttributes(traits)
        }
    }

    fun toISO8601Date(dateString: String?): Date? {
        if (dateString.isNullOrEmpty()) {
            return null
        }

        val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
        return try {
            sdf.parse(dateString)
        } catch (e: Exception) {
            Log.e(javaClass.name, "toISO8601Date: ${e.message}")
            null
        }
    }
}
