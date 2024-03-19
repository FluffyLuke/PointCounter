from tkinter import *
import counter

inputWindow = None
scoreWindow = None

currentPage = None
numberOfPages = None

pages = list()

def addPage(page: Frame):
    global numberOfPages

    pages.append(page)
    numberOfPages.set(numberOfPages.get()+1)
    for page in pages:
        page.changePageNumberText()

def removePage(page: Frame):
    global numberOfPages

    pages.append(page)
    numberOfPages.set(numberOfPages.get()-1)
    for page in pages:
        page.changePageNumberText()

def main():

    global currentPage 
    global numberOfPages 

    inputWindow = Tk()
    inputWindow.title("Score input")
    inputWindow.geometry('1500x1000')
    inputWindow.configure(background="light blue")

    currentPage = IntVar(inputWindow, 1)
    numberOfPages = IntVar(inputWindow, 0)

    topPanel = Frame(inputWindow, height=900, width=1500)
    topPanel.pack(side=TOP, expand=True)
    bottomPanel = Frame(inputWindow, height=100, width=1500)
    bottomPanel.pack(side=BOTTOM, expand=False)

    # TODO remove later
    topPanel.configure(background="red")
    bottomPanel.configure(background="blue")

    # Top panel configuration
    startingPage = counter.StartingPage(topPanel)
    addPage(startingPage)

    # Bottom panel configuration
    leftButton = Button(bottomPanel, text="PREVIOUS")
    rightButton = Button(bottomPanel, text="NEXT")

    leftButton.pack(side=LEFT)
    rightButton.pack(side=LEFT)

    inputWindow.mainloop()

if __name__ == "__main__": 
    main()