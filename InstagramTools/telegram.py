#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Import with error handling
import os
import sys
import platform

# Check if running on Windows 11
is_windows11 = platform.system() == "Windows" and platform.release() == "11"

try:
    import telegram
    from telegram.ext import Updater, CommandHandler, MessageHandler, Filters
    
    # Test the telegram module to ensure it's working properly
    def test_telegram_connection():
        try:
            # Load telegram configuration from JSON file
            import json
            config_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "telegram_config.json")
            
            if os.path.exists(config_file):
                with open(config_file, "r") as f:
                    config = json.load(f)
                    token = config.get("token", "")
                
                if token:
                    # Just create a bot instance to test the connection
                    bot = telegram.Bot(token=token)
                    return True
                else:
                    print("\033[93mWarning: Telegram token is not configured. Notifications will be disabled.\033[0m")
                    return False
            else:
                print("\033[93mWarning: telegram_config.json not found. Notifications will be disabled.\033[0m")
                return False
        except Exception as e:
            print(f"\033[91mError testing Telegram connection: {e}\033[0m")
            return False
    
    # Initialize Telegram functionality
    def init_telegram():
        if test_telegram_connection():
            print("\033[92mTelegram notifications are ready!\033[0m")
            return True
        return False
    
    # Send a message via Telegram
    def send_message(message):
        try:
            import json
            config_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "telegram_config.json")
            
            if os.path.exists(config_file):
                with open(config_file, "r") as f:
                    config = json.load(f)
                    token = config.get("token", "")
                    chat_id = config.get("chat_id", "")
                
                if token and chat_id:
                    bot = telegram.Bot(token=token)
                    bot.send_message(chat_id=chat_id, text=message)
                    return True
                else:
                    print("\033[93mWarning: Telegram token or chat_id not configured. Message not sent.\033[0m")
                    return False
            else:
                print("\033[93mWarning: telegram_config.json not found. Message not sent.\033[0m")
                return False
        except Exception as e:
            if is_windows11:
                print("\033[91mError sending Telegram message on Windows 11.\033[0m")
                print("\033[93mThis may be due to Windows 11 security policies or network settings.\033[0m")
            print(f"\033[91mError details: {e}\033[0m")
            return False

except ImportError as e:
    print(f"\033[91mError importing telegram module: {e}\033[0m")
    
    if is_windows11:
        print("\033[93mOn Windows 11, you may need to install the module manually:\033[0m")
        print("  1. Open Command Prompt as Administrator")
        print("  2. Run: pip install python-telegram-bot==13.15")
    else:
        print("\033[93mPlease install the required module:\033[0m")
        print("  pip install python-telegram-bot==13.15")
    
    # Define placeholder functions that do nothing
    def init_telegram():
        return False
        
    def send_message(message):
        print(f"\033[93mTelegram notification disabled: {message}\033[0m")
        return False
        
    if not os.environ.get("INSTAGRAM_TOOLS_SILENT", ""):
        sys.exit(1) 