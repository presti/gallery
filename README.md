# gallery

Sample Image browsing app


This app shows a grid of images taken from Imgur, with the possibility to open one of them or search through images.

GetIt is used for injection and routing.

This sample has almost no work done on UI or UX. A basic first UX approach would be to implement a Pager on the Image Description Page, to scroll through the images. Another improvement would be adding an automatic retry to some of the http requests, or at least adding a retry button in the Image description, where if the loading fails you currently see a failure image.

Regarding the coding, a simplistic (but adaptable) approach was used. Unfortunately this means that there are no ValueObjects. There is a model that has all "primitive" fields with no validation, except checking for null.

There are sample tests for some classes. In these, unfortunately there are not mocked calls to test.
