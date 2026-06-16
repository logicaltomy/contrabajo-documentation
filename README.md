# Documentacion y Auditoria Tecnica - Contrabajo

Este repositorio centraliza la documentacion funcional, tecnica y de gestion del proyecto **Contrabajo**, desarrollado por el equipo **Zerberus Softwork** en el contexto de *Taller Aplicado de Programacion (TPY1101)*.

Contrabajo es una plataforma movil orientada a la intermediacion de servicios tecnicos. Su arquitectura combina una app Android nativa con un backend distribuido en microservicios, una base de datos relacional y una capa de despliegue desacoplada mediante contenedores.

## Descripcion General

La solucion fue pensada para conectar clientes y tecnicos dentro de un marketplace de servicios. El ecosistema se compone de:

- Una aplicacion movil Android construida en Kotlin.
- Un backend basado en microservicios con Java 21 y Spring Boot 3.x.
- Un servidor de configuracion centralizada con Spring Cloud Config Server.
- Una base de datos relacional en Microsoft SQL Server 2022, con opcion de despliegue en Azure SQL Server.
- Infraestructura de despliegue mediante Docker y Docker Compose.

## Estructura del Repositorio

### Documentacion

Contiene artefactos de analisis, diseno y soporte visual del sistema:

- Diagramas UML.
- Modelo entidad-relacion.
- Manual unificado del proyecto.
- Informes de avance y material de apoyo.

### Producto

Agrupa los recursos tecnicos del sistema:

- Scripts SQL por microservicio.
- Procedimientos almacenados.
- Referencias a los repositorios oficiales del ecosistema.

### Gestion

Reune los documentos administrativos y de organizacion del equipo:

- Presentaciones.
- Evidencias de avance.
- Registro de integrantes.

## Stack Tecnologico

### 1. Frontend (Aplicacion Movil)

La capa cliente esta desarrollada como una app movil nativa para Android:

- **Kotlin:** lenguaje principal para la logica de negocio, navegacion y consumo de datos en la aplicacion.
- **Android SDK:** framework nativo utilizado para la construccion de pantallas, componentes visuales, manejo del ciclo de vida y acceso a capacidades del dispositivo.
- **Retrofit 2 y OkHttp:** librerias HTTP encargadas del consumo de APIs REST, serializacion de respuestas JSON y configuracion de interceptores para autenticacion.
- **Gradle (Kotlin DSL / Groovy):** sistema de build y gestion de dependencias, usado para controlar versiones, perfiles de compilacion y variables por entorno.

### 2. Backend (Arquitectura de Microservicios)

El backend esta desacoplado en servicios independientes, construidos sobre el ecosistema Java y Spring:

- **Java 21:** version base del lenguaje para todos los microservicios del backend.
- **Spring Boot 3.x:** framework principal para exponer APIs REST, configurar dependencias y acelerar el desarrollo de servicios.
- **Spring Cloud Config Server:** servidor centralizado de configuracion que obtiene propiedades desde un repositorio Git y las distribuye a los microservicios durante su arranque.
- **Spring Security y JWT:** capa de autenticacion y autorizacion basada en tokens, con control de accesos por roles como `TECNICO` y `CLIENTE`.
- **Spring Data JPA / Hibernate:** ORM utilizado para mapear entidades Java a tablas SQL y simplificar la persistencia relacional.

Microservicios principales:

- **usuarios-api (puerto 8081):** administra cuentas, perfiles, autenticacion con JWT, registro y preguntas de seguridad.
- **servicios-api (puerto 8082):** gestiona publicaciones de servicios, busquedas, categorias y coordinacion de citas.
- **comunicaciones-api (puerto 8083):** concentra chat entre usuarios, mensajeria de soporte y reportes para moderacion.
- **fotos-api (puerto 8084):** procesa y almacena imagenes asociadas a ofertas y verificacion de identidad.

### 3. Base de Datos y Almacenamiento

La persistencia del sistema se apoya en tecnologias del ecosistema Microsoft:

- **Microsoft SQL Server 2022:** motor relacional principal para usuarios, ofertas, chats, citas, reportes y datos operacionales.
- **Azure SQL Server (opcional):** alternativa de despliegue administrado en la nube para ambientes remotos.
- **T-SQL:** lenguaje usado para scripts de inicializacion, definicion de tablas, procedimientos almacenados, triggers y separacion de esquemas por servicio.

### 4. Infraestructura, Despliegue y DevOps

El entorno tecnico busca que el sistema pueda reproducirse de forma consistente entre desarrollo y despliegue:

- **Docker:** encapsula cada microservicio, el config server y la base de datos en contenedores aislados.
- **Docker Compose:** orquesta el levantamiento del ecosistema completo con redes internas, variables de entorno y volumenes persistentes mediante `docker compose up`.
- **Docker Hub:** repositorio de imagenes para distribuir componentes preconstruidos del backend.

### 5. Herramientas de Desarrollo y Pruebas

El flujo de trabajo del equipo se apoya en herramientas especializadas para desarrollo, validacion y documentacion:

- **Visual Studio Code:** editor recomendado para backend, documentacion y revision de scripts.
- **Android Studio:** entorno oficial para desarrollo, emulacion y depuracion de la aplicacion Android.
- **Postman:** herramienta para probar colecciones HTTP y validar endpoints de los microservicios.
- **Swagger UI / OpenAPI:** documentacion interactiva generada por cada servicio para inspeccionar contratos y probar APIs desde el navegador.
- **Git y GitHub:** control de versiones del codigo fuente y almacenamiento de repositorios, incluyendo configuraciones centralizadas.

## Repositorios Oficiales y Estructura de `links_git`

Si el proyecto esta dividido en varios repositorios, `links_git` debe registrar **todos los enlaces dentro de la misma celda**, separados por punto y coma (`;`) o en renglones distintos.

Formato consolidado sugerido para Contrabajo:

```text
https://github.com/lPacal/contrabajo-usuarios-api;
https://github.com/lPacal/contrabajo-servicios-api;
https://github.com/lPacal/contrabajo-comunicaciones-api;
https://github.com/lPacal/contrabajo-fotos-api;
https://github.com/lPacal/contrabajo-config-server;
https://github.com/NikoGox/contrabajo-deploy;
https://github.com/NikoGox/Contrabajo-App
```

Repositorios del ecosistema:

- **contrabajo-usuarios-api:** microservicio de usuarios, autenticacion y perfiles. Rama objetivo: `integracion`.
- **contrabajo-servicios-api:** microservicio de ofertas, categorias y agenda de servicios. Rama objetivo: `integracion`.
- **contrabajo-comunicaciones-api:** microservicio de chat, soporte y reportes. Rama objetivo: `integracion`.
- **contrabajo-fotos-api:** microservicio de almacenamiento y procesamiento de imagenes. Rama objetivo: `main`.
- **contrabajo-config-server:** servidor centralizado de configuracion. Rama objetivo: `main`.
- **contrabajo-deploy:** repositorio de orquestacion y despliegue con Docker Compose. Rama objetivo: `main`.
- **Contrabajo-App:** aplicacion movil Android del proyecto. Rama objetivo: `main`.

## Preparacion del Entorno de Trabajo

Para clonar el ecosistema completo del proyecto en una carpeta local:

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

## Infraestructura y Despliegue

El proyecto fue concebido para ejecutarse de manera consistente tanto en entornos locales como en nube:

- Uso de contenedores para aislar servicios y dependencias.
- Configuracion desacoplada mediante servidor centralizado.
- Posibilidad de desplegar base de datos en SQL Server local o Azure SQL Server.
- Separacion clara entre frontend movil, backend distribuido y repositorio de infraestructura.

## Calidad y Pruebas

La estrategia de calidad del proyecto contempla:

- Pruebas unitarias e integracion por servicio.
- Validacion de requerimientos funcionales y no funcionales.
- Revision de contratos API mediante Swagger UI.
- Pruebas manuales y automatizadas de endpoints con Postman.

## Equipo de Desarrollo

- **Ruben Parada** - Project Lead & Scrum Master
- **Cristobal Barrientos** - Backend & Integration Specialist
- **Tomas Zapata** - Product Owner & Data Architect

## Consideraciones Finales

Este repositorio documenta la evolucion tecnica y organizacional de Contrabajo. Su objetivo es facilitar la auditoria, la trazabilidad de entregables y la comprension del ecosistema completo de repositorios, tecnologias y componentes utilizados por el equipo.
