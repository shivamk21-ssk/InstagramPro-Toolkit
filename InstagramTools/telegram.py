

try:
  
    import telegram

except ImportError as e:
    print(f"Error importing telegram module: {e}")
   
    import sys
    sys.exit(1) 