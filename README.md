# ft_transcendence

add healt endpoint on each micro service
ameliorer git ignore
rajouter env postgre sur user management pour db acces
choisir entre rerun et guard pour hot reloading

```
ft_transcendence/
├── .env
├── Makefile
├── docker-compose.yml
├── nginx/
│   ├── Dockerfile
│   ├── default.conf
│   └── generate_cert.sh
├── ruby_user_management/
│   ├── Dockerfile
│   ├── Gemfile
│   ├── Gemfile.lock
│   ├── app/
│   │   ├── controllers/
│   │   │   └── main_controller.rb
│   │   ├── models/
│   │   │   └── user.rb
│   │   ├── services/
│   │   │   └── token_manager.rb
│   │   ├── log/
│   │   │   └── custom_logger.rb
│   ├── config/
│   │   ├── database.rb
│   │   └── environment.rb
│   ├── app.rb
├── ruby_ssr/
│   ├── Dockerfile
│   ├── Gemfile
│   ├── Gemfile.lock
│   ├── app/
│   │   ├── controllers/
│   │   │   └── ssr_controller.rb
│   │   ├── log/
│   │   │   └── custom_logger.rb
│   ├── config/
│   │   └── environment.rb
│   ├── app.rb
└── postgres/
    └── Dockerfile
```
