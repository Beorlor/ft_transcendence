# ft_transcendence

add healt endpoint on each micro service

ssr connector vers user management

connection db et injection logger

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



kibana pattern : nginx-access-logs-*