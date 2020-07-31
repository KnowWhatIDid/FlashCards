# FlashCards
Script for creating and displaying flash cards.

Version 0.0.0
Pretty rough at this point.  

The script reads a .json file that contains the informatin for the cards' front and back.  Right now, the information is displayed in message boxes.  Beautification in the form of Windows forms is coming (soon?).

New-FlashCard Function
This function will add flash card information to a .json file.  It will create the file if it doesn not exist.
-Path is used to specify the .json file.
-NewCard is used to pass a (get ready for this) comma-delimited list of pipe-delimited strings containing the information for the front|back of the card.

Example:
New-FlashCard -Path .\Multiplication.json -NewCard '3x3|9','2x8|16'

Show-FlashCard Function
Displays the flash cards in a random order. The user has the option to repeat the list of cards a specified number of times (1 to infinity).  The user can also elect to show the front of the card first, the back of the card first, or randomize which is shown.  In the mulitplication example, it doen't make sense to show anything but the front first, but it could make sense in the case of vocabulary words, or studying AWS services.

Example
To show each card once, showing the front side first,
Show-FlashCard -Path .\Multiplication.json -Repeat 1 -ShowSide Front

To show each card in an endless loop, showing a random side first,
Show-FlashCard -Path .\AWS_Compute_Services.json -Repeat 0 -ShowSide Random

-Repeat 0 and -ShowSide Random are actually the defaults so you could just execute
Show-FlashCArd -Path .\AWS_Compute_Services.json

Wishlist
1.  Create forms that display the text a little better.
2.  Create forms that have 'Flip Card' and 'Next Card' buttons.


