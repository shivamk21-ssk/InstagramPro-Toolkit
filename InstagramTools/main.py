

# scripted by zork 

try:
    
    from instagram_tools import *
    
 
    def run():
     
        pass
        
  
    if __name__ == "__main__":
        run()
        
except ImportError:
    
    import sys
    
    def show_error():
        print("\033[91mError!\033[0m")
       
    
    # Show the error message if this file is run directly
    if __name__ == "__main__":
        show_error()
        sys.exit(1) 