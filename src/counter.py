from tkinter import *
import main

class PageWidget(Frame):
    def __init__(self, root, playerCount: int, tableCount: int):
        super().__init__(root)
        self.playerCount = playerCount
        self.tableCount = tableCount

class StartingPage(Frame):
    def __init__(self, root):
        super().__init__(root)
        self.pack()
        self.pageNumber = 1
        self.pageNumberText = StringVar()
        
        newPageButton = Button(self, text="Create new page")
        newPageButton.pack(side=TOP)

        pageLabel = Label(self, textvariable=self.pageNumberText)
        pageLabel.place(x=10, y=10)

    def changePageNumberText(self):
        self.pageNumberText.set("Page 1/"+str(main.numberOfPages.get()))


class Player:
    def __init__(self, name: str, lastname: str):
        self.name = name
        self.lastname = lastname
        self.rounds = list()

class Round:
    def __init__(self, player1: Player, player2: Player):
        self.player1 = player1
        self.player2 = player2
        self.player1Points = IntVar()
        self.player2Points = IntVar()
        self.player1SmallPoints = IntVar()
        self.player2SmallPoints = IntVar()