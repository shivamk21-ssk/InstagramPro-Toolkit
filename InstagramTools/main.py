


# scripted by zork 
import os
import sys
import platform

# Check Python version
def check_python_version():
    current_version = platform.python_version()
    required_version = "3.13.2"
    if current_version != required_version:
        print(f"\033[93mWarning: You are using Python {current_version}, but Python {required_version} is recommended.\033[0m")
        return False
    return True

# Check operating system
def check_os():
    os_name = platform.system()
    if os_name != "Windows":
        print(f"\033[93mWarning: This tool is optimized for Windows, but you're running on {os_name}.\033[0m")
        return False
    
    if platform.release() == "11":
        # Windows 11 specific checks
        print("Windows 11 detected. Performing additional compatibility checks...")
        return check_windows11_compatibility()
    
    return True

# Check Windows 11 compatibility
def check_windows11_compatibility():
    # Check if PATH is properly set
    python_in_path = False
    path_dirs = os.environ.get("PATH", "").split(os.pathsep)
    for path_dir in path_dirs:
        if os.path.exists(os.path.join(path_dir, "python.exe")):
            python_in_path = True
            break
    
    if not python_in_path:
        print("\033[91mError: Python is not properly added to PATH environment variable.\033[0m")
        print("This is a common issue on Windows 11.")
        print("Please run the Instagram_Pro.bat file as administrator to fix this problem.")
        return False
    
    return True

# Verify required modules
def check_required_modules():
    required_modules = [
        "instaloader", 
        "requests", 
        "telegram", 
        "urllib3", 
        "certifi", 
        "bs4", 
        "fake_useragent"
    ]
    
    missing_modules = []
    
    for module in required_modules:
        try:
            __import__(module)
        except ImportError:
            missing_modules.append(module)
    
    if missing_modules:
        print("\033[91mError: The following required modules are missing:\033[0m")
        for module in missing_modules:
            print(f"  - {module}")
        print("\nPlease run the Instagram_Pro.bat file to automatically install these dependencies.")
        print("Or manually install them with: pip install " + " ".join(missing_modules))
        return False
    
    return True

# Main function
try:
    # First perform compatibility checks
    if not check_python_version() or not check_os():
        print("\033[93mContinuing despite warnings...\033[0m")
    
    if not check_required_modules():
        print("\033[91mExiting due to missing dependencies.\033[0m")
        sys.exit(1)
    
    # Try to import the compiled module
    from instagram_tools import *
    
    # Define an entry point function
    def run():
        """Run the Instagram Tools application."""
        # The main application should already run on import
        # This function is provided for clarity and as a backup
        print("\033[92mStarting Instagram Tools...\033[0m")
        # Add any additional startup code here
        pass
        
    # If this file is executed directly, run the application
    if __name__ == "__main__":
        run()
        
except ImportError as e:
    # If the compiled module is not found, show an error message
    def show_error():
        print("\033[91mError: Instagram tools module not found!\033[0m")
        print(f"\033[91mError details: {e}\033[0m")
        print("\033[93mPlease make sure all files are in the correct location.\033[0m")
        print("\033[93mIf you're running Windows 11, try running Instagram_Pro.bat as administrator.\033[0m")
    
    # Show the error message if this file is run directly
    if __name__ == "__main__":
        show_error()
        sys.exit(1)
except Exception as e:
    # Handle any other unexpected errors
    print(f"\033[91mUnexpected error: {e}\033[0m")
    print("\033[93mPlease report this issue or run Instagram_Pro.bat as administrator to fix it.\033[0m")
    sys.exit(1) 
