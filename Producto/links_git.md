# Anexo: Indice de Repositorios Oficiales del Proyecto

Para la revision del ecosistema de Contrabajo, el campo `links_git` debe consolidar todos los repositorios del proyecto cuando exista una arquitectura distribuida en multiples fuentes.

## Estructura esperada para `links_git`

Si el proyecto esta dividido en varios repositorios, deben registrarse **todos los links dentro de la misma celda**, separados por punto y coma (`;`) o en renglones distintos.

Formato sugerido:

```text
https://github.com/lPacal/contrabajo-usuarios-api;
https://github.com/lPacal/contrabajo-servicios-api;
https://github.com/lPacal/contrabajo-comunicaciones-api;
https://github.com/lPacal/contrabajo-fotos-api;
https://github.com/lPacal/contrabajo-config-server;
https://github.com/NikoGox/contrabajo-deploy;
https://github.com/NikoGox/Contrabajo-App
```

## Repositorios del Proyecto Contrabajo

| Repositorio | Rama recomendada | Enlace | Contenido |
| --- | --- | --- | --- |
| `contrabajo-usuarios-api` | `integracion` | https://github.com/lPacal/contrabajo-usuarios-api | Microservicio de usuarios, autenticacion JWT, perfiles, registro y seguridad. |
| `contrabajo-servicios-api` | `integracion` | https://github.com/lPacal/contrabajo-servicios-api | Microservicio de ofertas, categorias, agenda y logica transaccional de servicios. |
| `contrabajo-comunicaciones-api` | `integracion` | https://github.com/lPacal/contrabajo-comunicaciones-api | Microservicio de chat, soporte, notificaciones y reportes. |
| `contrabajo-fotos-api` | `main` | https://github.com/lPacal/contrabajo-fotos-api | Microservicio de almacenamiento y procesamiento de imagenes. |
| `contrabajo-config-server` | `main` | https://github.com/lPacal/contrabajo-config-server | Servidor centralizado de configuracion para los microservicios. |
| `contrabajo-deploy` | `main` | https://github.com/NikoGox/contrabajo-deploy | Orquestacion de contenedores, variables de entorno y despliegue con Docker Compose. |
| `Contrabajo-App` | `main` | https://github.com/NikoGox/Contrabajo-App | Aplicacion movil Android desarrollada en Kotlin. |

## Clonacion del Ecosistema Completo

```bash
# 1. Crear la carpeta para el entorno y acceder a ella
mkdir -p espacio-contrabajo && cd espacio-contrabajo

# 2. Microservicios del Core Backend (clonados directamente en la rama integracion)
git clone -b integracion https://github.com/lPacal/contrabajo-usuarios-api.git
git clone -b integracion https://github.com/lPacal/contrabajo-servicios-api.git
git clone -b integracion https://github.com/lPacal/contrabajo-comunicaciones-api.git

# 3. Microservicio de soporte (si no tiene rama de integracion, se usa main)
git clone https://github.com/lPacal/contrabajo-fotos-api.git

# 4. Servidor de configuracion centralizada (rama main)
git clone https://github.com/lPacal/contrabajo-config-server.git

# 5. Orquestacion, Docker Compose y despliegue (rama main)
git clone https://github.com/NikoGox/contrabajo-deploy.git

# 6. Aplicacion frontend movil Android (rama main)
git clone https://github.com/NikoGox/Contrabajo-App.git
```
