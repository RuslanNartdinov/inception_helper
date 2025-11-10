11.06
Improve env template so ir's possible to add server name and
Change "sabdulki" everywhere to corresponding env variable
Chnage paths in volumes so other users can also store their data there
Add info about most used commands to interact with running application
(docker logs, docker ps -a, docker exec mariadb sh, show databases; etc)
Will the site work if domain name contains non-existing 42 nickname?
29.05

как запускать правильно контейнер

вообще все что связано с докером

сейчса я написала докер и конф для nginx, но я не могу запустить контейнер(хотя я его сбилдила), возможно неправильно вызываю комнаду.

Successfully built f3bbd2826f33
Successfully tagged nginx:latest
sabdulki@debian:~/project/srcs/requirements/nginx$ docker run -d -p 443:443 --name nginx nginx
docker: Error response from daemon: Conflict. The container name "/nginx" is already in use by container "e94e5a4747e7380f0562fb61727a34b4c50f892d0e514e042c297a32343be00e". You have to remove (or rename) that container to be able to reuse that name.
See 'docker run --help'.

30.05 
1) я запустила nginx контейнер
2) разобралась со всеми docker командами

Как убедиться, что всё работает:
Ты уже сделал:
Контейнер запущен ✅
Порт 443 проброшен ✅

Теперь попробуй:
curl -k https://sabdulki.42.fr

мой ответ 403 Forbidden 
``` HTML
<html>
<head><title>403 Forbidden</title></head>
<body bgcolor="white">
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.14.2</center>
</body>
```

3) создала mariadb контейнер, в нем создалаcь чистая таблица и юзеры - root и обычный

31.05
как вместе работают nginx и php?
Браузер запрашивает index.php через Nginx.

Nginx понимает, что это PHP-файл и перенаправляет запрос через FastCGI на сокет (например, /run/php/php-fpm.sock).

PHP-FPM получает запрос и вызывает интерпретатор PHP.

PHP обрабатывает index.php, генерирует HTML.

PHP-FPM отдает результат обратно в Nginx → браузеру.

1) сделала wordpress контейнер
2) сделала docker-compose.yml
3) сблидила docker-compose.yml

сайт не показывается, wordpress не выходит нормально, а убивается с кодом 137. 
нужно проверить сколько памяти он ест и нужно ли выделить больше памяти вордпрессу.
нужно проверить относятся ли хранилища nginx и wordpress к одному тому, а не просто к путсым папкам с одинкавыми названиями.

контейнеры находятся в одной сети, слушают по верным портам, nginx слушает wordpress и наоборот. 

устраненные ошибки - учебный nginx контейнер слушал 443, убрала второй контейнер
default.conf лежал в nginx, а должен был в nginx/conf.d/ я переместила


4) ВСЕ РАБОТАЕТ в startx webserver!!!!!

Preparation! 
Questions:
- whats the difference between virtual machine and docker
- how daemons work and whether it’s a good idea to use them or not. runs invisibly, background process
- what is pid 1, how it's defined and how to check if the docker uses pid 1. first process started by the Linux kernel, ofthen runs as root
- what is ssl protocol, what are the stages of handshake? 
- what is TLSv1.2 and TLSv1.3 protocol
- how do we configure ssl certificate
- differnce betweeen localhost and domain name

- what is VM?
- what is Docker?
- what are docker image, docker container, docker volumes and docker network
- what is docker compose?

- what is nginx?
- what is mariadb
- what is wordpress?

- what is startx?
- what is web browser?

- how to prove that i use ssl/tls certificate?

Action needed:
+ delete all debug messages
+ delete all empty folders
+ delete "srcs_" prefix or make sure it's allowed to present
+ add todo.md in .gitignor