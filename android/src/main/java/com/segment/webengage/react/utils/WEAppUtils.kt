package com.segment.webengage.react.utils

import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReadableMapKeySetIterator
import com.facebook.react.bridge.ReadableType
import com.webengage.sdk.android.Logger
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap

class WEAppUtils {

    private val TAG = WEAppUtils::class.java.simpleName
    private val DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    private val DATE_FORMAT_LENGTH = DATE_FORMAT.replace("'".toRegex(), "").length

    public fun getApplicationMetaData(context: Context): Bundle? {
        return try {
            val ai = context.packageManager.getApplicationInfo(
                context.packageName,
                PackageManager.GET_META_DATA
            )
            ai.metaData
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    public fun recursivelyDeconstructReadableMap(readableMap: ReadableMap): MutableMap<String, Any?> {
        val iterator: ReadableMapKeySetIterator = readableMap.keySetIterator()
        val deconstructedMap: MutableMap<String, Any?> = HashMap()
        while (iterator.hasNextKey()) {
            val key: String = iterator.nextKey()
            val type: ReadableType = readableMap.getType(key)
            when (type) {
                ReadableType.Null -> deconstructedMap[key] = null
                ReadableType.Boolean -> deconstructedMap[key] = readableMap.getBoolean(key)
                ReadableType.Number -> deconstructedMap[key] = readableMap.getDouble(key)
                ReadableType.String -> {
                    val value: String? = readableMap.getString(key)
                    if (value !=null && value.length == DATE_FORMAT_LENGTH) {
                        val date: Date? = getDate(value)
                        if (date != null) {
                            deconstructedMap[key] = date
                        } else {
                            deconstructedMap[key] = value
                        }
                    } else {
                        deconstructedMap[key] = value
                    }
                }
                ReadableType.Map -> {
                    val nestedMap = recursivelyDeconstructReadableMap(readableMap.getMap(key)!!)
                    deconstructedMap[key] = nestedMap
                }
                ReadableType.Array -> {
                    val nestedList = recursivelyDeconstructReadableArray(readableMap.getArray(key)!!)
                    deconstructedMap[key] = nestedList
                }
                else -> Logger.e(TAG, "Could not convert object with key: $key")
            }
        }
        return deconstructedMap
    }

    private fun recursivelyDeconstructReadableArray(readableArray: ReadableArray): List<Any?> {
        val deconstructedList: MutableList<Any?> = ArrayList(readableArray.size())
        for (i in 0 until readableArray.size()) {
            val indexType: ReadableType = readableArray.getType(i)
            when (indexType) {
                ReadableType.Null -> deconstructedList.add(i, null)
                ReadableType.Boolean -> deconstructedList.add(i, readableArray.getBoolean(i))
                ReadableType.Number -> deconstructedList.add(i, readableArray.getDouble(i))
                ReadableType.String -> {
                    val value: String = readableArray.getString(i)
                    if (value.length == DATE_FORMAT_LENGTH) {
                        val date: Date? = getDate(value)
                        if (date != null) {
                            deconstructedList.add(i, date)
                        } else {
                            deconstructedList.add(i, value)
                        }
                    } else {
                        deconstructedList.add(i, value)
                    }
                }
                ReadableType.Map -> deconstructedList.add(i, recursivelyDeconstructReadableMap(readableArray.getMap(i)!!))
                ReadableType.Array -> deconstructedList.add(i, recursivelyDeconstructReadableArray(readableArray.getArray(i)!!))
                else -> Logger.e(TAG, "Could not convert object at index $i")
            }
        }
        return deconstructedList
    }

    private fun getDate(value: String): Date? {
        return try {
            SimpleDateFormat(DATE_FORMAT).parse(value)
        } catch (e: ParseException) {
            Logger.e(TAG, "Error parsing date: $value")
            null
        }
    }
}
