# ansible-roles
Repositórios de roles que usamos em nossos playbooks. Os roles de Windows possuem prefixo `win_`.

## base
Repositórios, pacotes e chaves de SSH.

## classroom
Depende do role `ui`. Lida com pacotes, autologin e screensaver. Usa a variável `classroom_user_password` para definir a senha do usuário de autologin.

## lab
Também depende do role `ui`. Pacotes.

## pam_mount
Cuida da montagem das homes usando o pam_mount.

## sssd-ad
Autenticação.

## ssh
Grupos autorizados e portas para SSH.

## ui
Pacotes e arcabouço de customização do dconf.

## radius-mpsk
Monta servidor de RADIUS configurado com certificado de EAP e módulo para MPSK (compatível só com Aruba).

É preciso dar chown nos arquivos gerados pelo certbot, por isso o deploy_hook.

```yml
  vars:
    certbot_admin_email: admin@ime.usp.br
    certbot_create_if_missing: true
    certbot_certs:
      - name: "{{ eap_domain }}"
        domains:
          - "{{ eap_domain }}"
        deploy_hook: /usr/local/bin/certbot_chown.sh
    certbot_create_standalone_stop_services:
      - freeradius

  roles:
    - radius-mpsk
    - geerlingguy.certbot
```
