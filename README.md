# thun
A web app to publish and analyze the correspondence of Loe von Thun-Hohenstein. A (hopefully soon to be deprecated) current version of such a web application can be found [here](http://thun-korrespondenz.uibk.ac.at:8080/exist/apps/Thun-Collection/index.html).

## technical things

The web app is based on eXist-db, a documentation of the basic code layout and the app's functionalities can be found [here](https://howto.acdh.oeaw.ac.at/blog/books/how-to-build-a-digital-edition-web-app/). 
The actual data, the XML/TEI encoded transcripts of the correspondence is not part of this repo but you can fetch the data from the ['old' application](http://thun-korrespondenz.uibk.ac.at:8080/exist/rest/db/files/thun/xml/)

### install

1. Browse to eXist-db's dashboard (in case eXist-db runs with default settings at localhost you can click [here](http://localhost:8080/exist/apps/dashboard/index.html))
2. Click on the **Package Manager** tile.
3. Click on the **add apackage** symbol in the top left corner
4. Click on **Upload** and
4. select the `thun\application-code\thun\build\thun-1.0.xar` 

