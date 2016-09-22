## Git

### Git blame number actions on a file by user

    git blame -w src/circle/model/action_log.clj | perl -pe 's/^.*\((.*?)\s+\d\d\d\d-\d\d-\d\d.*/$1/' | sort | uniq -c | sort -nr
    60 Conor McDermottroe
    53 Ian Davis
    51 Allen Rohner
    47 Paul Biggar
    21 Justin Cowperthwaite
    18 Mahmood Ali
    10 Gordon Syme
     8 J. David Lowe
     5 Marc O'Morain
     4 Daniel Woelfel
     1 Brandon Bloom

## Docker

### Destroy Everything, Rebuild Everything

    docker-compose rm -f
    docker-compose pull
    docker-compose up --build -d
