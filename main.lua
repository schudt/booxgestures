local Device = require("device")

if not Device:isAndroid() then
    return { disabled = true }
end

local android = require("android")
local ffi = require("ffi")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")

local BOTTOM_SETTING = "boox_bottom_gestures_disabled"
local TOP_SETTING = "boox_top_gestures_disabled"
local BOTTOM_ACTION = "com.onyx.action.BOTTOM_GESTURE_ENABLE"
local TOP_ACTION = "com.onyx.action.TOP_GESTURE_ENABLE"

local BooxGestures = WidgetContainer:extend{
    name = "booxgestures",
    is_doc_only = false,
}

function BooxGestures:isBottomDisabled()
    return G_reader_settings:isTrue(BOTTOM_SETTING)
end

function BooxGestures:isTopDisabled()
    return G_reader_settings:isTrue(TOP_SETTING)
end

function BooxGestures:apply(action_name, disabled)
    local ok, sent = pcall(function()
        return android.jni:context(android.app.activity.vm, function(jni)
            local env = jni.env
            local intent_class = env[0].FindClass(env, "android/content/Intent")
            local constructor = env[0].GetMethodID(
                env,
                intent_class,
                "<init>",
                "(Ljava/lang/String;)V"
            )
            local action = env[0].NewStringUTF(env, action_name)
            local intent = env[0].NewObject(env, intent_class, constructor, action)
            local key = env[0].NewStringUTF(env, "args_enable")
            local put_extra = env[0].GetMethodID(
                env,
                intent_class,
                "putExtra",
                "(Ljava/lang/String;Z)Landroid/content/Intent;"
            )

            env[0].CallObjectMethod(
                env,
                intent,
                put_extra,
                key,
                ffi.new("bool", not disabled)
            )
            jni:callVoidMethod(
                android.app.activity.clazz,
                "sendBroadcast",
                "(Landroid/content/Intent;)V",
                intent
            )

            local exception = env[0].ExceptionOccurred(env)
            if exception ~= nil then
                env[0].ExceptionDescribe(env)
                env[0].ExceptionClear(env)
                env[0].DeleteLocalRef(env, exception)
            end
            env[0].DeleteLocalRef(env, key)
            env[0].DeleteLocalRef(env, intent)
            env[0].DeleteLocalRef(env, action)
            env[0].DeleteLocalRef(env, intent_class)
            return exception == nil
        end)
    end)
    return ok and sent
end

function BooxGestures:setGestureDisabled(setting, action, disabled, label, notify)
    if not self:apply(action, disabled) then
        if notify then
            UIManager:show(InfoMessage:new{
                text = _("Could not change ") .. label .. _(" gestures."),
            })
        end
        return false
    end

    G_reader_settings:saveSetting(setting, disabled)
    if notify then
        UIManager:show(InfoMessage:new{
            text = disabled and label .. _(" gestures disabled")
                or label .. _(" gestures enabled"),
            timeout = 2,
        })
    end
    return true
end

function BooxGestures:init()
    self.ui.menu:registerToMainMenu(self)
    self:apply(BOTTOM_ACTION, self:isBottomDisabled())
    self:apply(TOP_ACTION, self:isTopDisabled())
end

function BooxGestures:onRequestSuspend()
    if self:isBottomDisabled() then
        self:apply(BOTTOM_ACTION, false)
    end
    if self:isTopDisabled() then
        self:apply(TOP_ACTION, false)
    end
end

function BooxGestures:onResume()
    if self:isBottomDisabled() then
        self:apply(BOTTOM_ACTION, true)
    end
    if self:isTopDisabled() then
        self:apply(TOP_ACTION, true)
    end
end

function BooxGestures:stopPlugin()
    local bottom_ok = self:apply(BOTTOM_ACTION, false)
    local top_ok = self:apply(TOP_ACTION, false)
    return bottom_ok and top_ok
end

function BooxGestures:addToMainMenu(menu_items)
    menu_items.boox_1_top_gestures = {
        text = _("Disable BOOX top gestures in KOReader"),
        sorting_hint = "screen",
        checked_func = function()
            return self:isTopDisabled()
        end,
        callback = function()
            self:setGestureDisabled(
                TOP_SETTING,
                TOP_ACTION,
                not self:isTopDisabled(),
                _("BOOX top"),
                true
            )
        end,
    }
    menu_items.boox_2_bottom_gestures = {
        text = _("Disable BOOX bottom gestures in KOReader"),
        sorting_hint = "screen",
        checked_func = function()
            return self:isBottomDisabled()
        end,
        callback = function()
            self:setGestureDisabled(
                BOTTOM_SETTING,
                BOTTOM_ACTION,
                not self:isBottomDisabled(),
                _("BOOX bottom"),
                true
            )
        end,
    }
end

return BooxGestures
