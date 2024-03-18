from tkinter import *


inputWindow = None
scoreWindow = None

def main():
    inputWindow = Tk()
    inputWindow.title("Score input")
    inputWindow.geometry('400x200')
    inputWindow.configure(background="light blue")

    

    inputWindow.mainloop()

if __name__ == "__main__": 
    main()