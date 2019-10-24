# Useful Scripts

Little things I tend to lookup _all_ the time...and don't ever change...

## Git

### Git blame number actions on a file by user

```sh
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
```

### Status of all repos

```sh
for d in *; do echo $d; git --git-dir=$d/.git --work-tree=$d branch -l; echo; done;
```

### Stale Branches

```sh
git fetch --prune
```

#### Merged Branches

##### Remote

https://gist.github.com/schacon/942899

##### Local

https://stackoverflow.com/a/6127884

```sh
git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d
```

### Forks

#### Syncing a fork/Keeping a fork up to date

https://gist.github.com/CristinaSolana/1885435

1. Clone your fork:

```sh
git clone git@github.com:YOUR-USERNAME/YOUR-FORKED-REPO.git
```

2. Add remote from original repository in your forked repository:

```sh
cd into/cloned/fork-repo
git remote add upstream git://github.com/ORIGINAL-DEV-USERNAME/REPO-YOU-FORKED-FROM.git
git fetch upstream
```

3. Updating your fork from original repo to keep up with their changes:

```sh
git pull upstream master
```

### Pull in files from another branch

```sh
git checkout <branch_name> -- <paths>
```

### Find checked in code, replace across the entire repo: `git grep ... sed ...`

Finds the files which have whatever pattern you're looking for, then pipes them into
`sed` which is able to replace all occurences of _any pattern_ in that files etc.

```sh
git grep -lz <whatever-youre-hoping-to-replace> \
| xargs -0 sed -i '' -e 's|<full-sed-pattern>|<full-sed-command>|g'
```

## Docker

```
docker system df
docker system prune -a
docker volume prune -a
docker image prune -a
```

### Compose Destroy Everything, Rebuild Everything

```
docker-compose stop
docker-compose rm -f
docker-compose build --pull #--force-rm --no-cache
docker-compose up -d
```

## Sublime

`cmd + d` in sublime to select multiple matches

## Regex

### Not: Negative Lookahead

```
(?!(<regex-pattern-here>).*)
```

## FS

### MAC: Port being used

```sh
sudo lsof -i -n -P | grep TCP | grep $PORT_NUMBER
```

### Mount Using SSHFS

```sh
umount -f ~/git/core-mount/ ; umount -f ~/.m2 ; rm -rf ~/git/core-mount/ ; rm -rf ~/.m2 ; mkdir ~/git/core-mount ; mkdir ~/.m2 ; sshfs core:/opt/code/ ~/git/core-mount ; sshfs core:/home/vagrant/.m2 ~/.m2
```

### `find`

#### By Name

```sh
find /the/path/to/the/dir -name <a-standard-regex>
```

## CLJ

### Atom Reseting Timing Results

```
(defmacro time-ret
  [expr]
  `(let [start# (. System (nanoTime))]
     ~expr
     (/ (double (- (. System (nanoTime)) start#)) 1000000.0)))
(let [numbers [1000
               5000
               10000
               50000
               100000
               500000
               1000000
               5000000
               10000000
               50000000
               100000000
               500000000
               1000000000]
      a (atom nil)
      timing (fn [n]
               [n
                (time-ret
                  (doseq [i (range n)]))
                (time-ret
                  (doseq [i (range n)]
                    (reset! a i)))])
      timings (map timing numbers)
      evalute-timing (fn [[n raw atomed]]
                       (/ (- atomed raw) n))
      evaluated-timings (map evalute-timing timings)
      avg-per-iteration-cost (/ (apply + evaluated-timings)
                                (count numbers))]
  (println "timings:" timings)
  (println "evaluated-timings:" evaluated-timings)
  (println "avg:" avg-per-iteration-cost))
timings: ([1000 0.338918 0.196144] [5000 0.658776 0.943233] [10000 1.241519 1.629284] [50000 5.146488 7.944602] [100000 12.51908 17.575708] [500000 1.584493 27.446502] [1000000 2.933393 16.679655] [5000000 14.3527 86.937824] [10000000 28.835396 172.397505] [50000000 143.544287 922.826021] [100000000 304.265204 1801.111753] [500000000 1491.142689 9064.28377] [1000000000 3072.72365 19251.725834])
evaluated-timings: (-1.4277399999999997E-4 5.689139999999999E-5 3.877649999999999E-5 5.596228E-5 5.056627999999998E-5 5.1724018000000004E-5 1.3746262E-5 1.4517024800000002E-5 1.43562109E-5 1.558563468E-5 1.4968465489999998E-5 1.5146282162E-5 1.6179002184000002E-5)
avg: 1.6588104632E-5
```

### Completely messed up ns in the repl

```
(remove-ns (ns-name *ns*))
```

### Tests Core.Test will run

```
(filter #(:test (meta %))
        (vals (ns-interns *ns*)))
```

### Sort Requires in an ns

```
(let [current-file-name (-> (ns-name *ns*)
                            str
                            (clojure.string/split #"\.")
                            second
                            (clojure.string/replace "-" "_")
                            (str ".clj"))
      pwd (->> "pwd"
               clojure.java.shell/sh
               :out
               clojure.string/trim)
      files (file-seq (clojure.java.io/file pwd))
      [file & err] (filter #(= current-file-name (.getName %))
                           files)]
  (when (seq err)
    (throw (ex-info "Too many files found!" {:target current-file-name
                                             :file file
                                             :err err})))
  (->> (slurp file)
       read-string
       (filter seqable?)
       (filter #(= :require (first %)))
       first
       rest
       sort
       (cons :require)))
```

A lesser form of the above, but equally useful for when your current proj is all sorts of messed up (ie, file structure is too messed to use above):

```
(cons :require (sort (rest '(:require ...))))
```

### Binding/With-Redefs Thread Confusion

http://blog.cognitect.com/blog/2016/9/15/works-on-my-machine-understanding-var-bindings-and-roots

```clj

(def ^:dynamic *answer* 42)
(defn answer [] *answer*)

(comment
  (println (answer))
  (binding [*answer* 0]
    (future
      (Thread/sleep 1000)
      (println "1" (answer))))
  (with-redefs [*answer* 0]
    (future
      (Thread/sleep 1000)
      (println "2" (answer))))
  (with-redefs [answer (constantly 0)]
    (future
      (Thread/sleep 1000)
      (println "3" (answer)))))

```

Outputs:

```clj
(println (answer))
42
=> nil
(binding [*answer* 0]
    (future
      (Thread/sleep 1000)
      (println "1" (answer))))
=> #future[{:status :pending, :val nil} 0x3fa806cb]
1 0
(with-redefs [*answer* 0]
    (future
      (Thread/sleep 1000)
      (println "2" (answer))))
=> #future[{:status :pending, :val nil} 0x67b9bf4e]
2 42
(with-redefs [answer (constantly 0)]
    (future
      (Thread/sleep 1000)
      (println "3" (answer))))
=> #future[{:status :pending, :val nil} 0x523d51b2]
3 42
```

## Python

### Reload Module in REPL

For Python2.x

```py
reload(module)
```

For above 2.x and <=Python3.3

```py
from imp import reload

reload(module)
```

For >=Python3.4

```py
from importlib import reload

reload(module)
```

## PostgreSQL

### Long Running Queries

```sql
SELECT
  pid,
  now() - pg_stat_activity.query_start AS duration,
  query,
  state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes';
```

### Kill Queries

```sql
SELECT pg_cancel_backend(__pid__);
```

```sql
SELECT pg_terminate_backend(__pid__);
```

> kill -9 in PostgreSQL. It will terminate the entire process which can lead to a full database restart in order to recover consistency.
