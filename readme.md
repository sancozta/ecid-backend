#### Passo a Passo Para Instalação (22.04)


        docker build -t sample-image .


        docker run -it sample-image bash


        cat /etc/lsb-release


        chmod 777 install-ecidade-ubuntu-22-04-postgresql-10.sh


        ./install-ecidade-ubuntu-22-04-postgresql-10.sh


        2 - America
        135 - Sao Paulo


        yes


        2 - Pegar SQL DEMO 


#### Depois de Terminar

        sudo nano /var/www/html/e-cidade/libs/db_conn.php
        alterar porta do postgress para 5433 (Esse banco instalado ele é SSL ativo)
        /etc/init.d/postgresql restart

        Acessar http://localhost/e-cidade/login.php
        Usuário: dbseller
        Senha: (Vazio)

Caso dê algum problema pode rodar o script novamente, parece que rodar o scripts uma segunda ou terceira vez não faz mal.

#### Removendo um postgress que não seja o 10

        sudo apt-get --purge remove postgresql-16 postgresql-client-16
        dpkg -l | grep postgres

#### Entrando no banco pela linha de comando 

        psql -U ecidade -d ecidade
        \l
        \c ecidade
        SELECT * FROM pg_catalog.pg_tables;
        ps aux | grep postgres

#### Alterar senha de algum usuário de banco 

        psql -U postgres
        ALTER USER ecidade WITH PASSWORD 'ecidade';
        \q
        /etc/init.d/postgresql restart

#### Instalando versões diferentes da 10 Postgres

        sudo apt install postgresql postgresql-contrib
        psql --version
        psql -h localhost -p 5433 -U ecidade -d ecidade