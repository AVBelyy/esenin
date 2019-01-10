# Esenin
![esenin screenshots](https://s3.eu-central-1.amazonaws.com/esenin/esenin-github-header.jpg)
Esenin is an online music player with à la karaoke lyrics highlighting. The player features six songs with lyrics, all of which are based on the poems of a 20th-century Russian poet [Sergey Esenin](https://en.wikipedia.org/wiki/Sergei_Yesenin).

The project was written overnight in 2013 (with minor updates in 2019) as a voluntary coursework for my Russian literature high school course to get more acquainted with Node.JS, CoffeeScript, Express, JADE, and, of course, to commemorate the great poet.

## How to run Esenin locally?

### Get the image from Docker Hub
```
$ docker pull tohnann/esenin
```

### Run the server
```
$ docker run -t -i -p 2109:2109 esenin
```

The player will be available at http://localhost:2109/
