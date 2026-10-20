
# Infraestructura Base AWS con Terraform

## 1. Descripción del proyecto

Proyecto desarrollado para el curso de Ingeniería de Datos en AWS de CoderHouse.

El objetivo es implementar una infraestructura base utilizando Terraform, siguiendo principios de modularización, seguridad y gobernanza.

La infraestructura prepara el entorno para futuros servicios de procesamiento y streaming de datos.

## 2. Tecnologías utilizadas

- AWS (Amazon Web Services)
- Terraform
- Amazon VPC
- Amazon S3
- Amazon DynamoDB
- AWS IAM
- Git y GitHub

## 3. Arquitectura implementada

### Módulo Network

- Una VPC con CIDR 10.0.0.0/16.
- Dos subredes privadas en distintas zonas de disponibilidad.
- Una tabla de rutas privada.
- Un S3 Gateway Endpoint.
- Sin acceso directo a Internet desde las subredes.

### Módulo Identity

- Rol IAM de ejecución para AWS Lambda.
- Permisos S3 limitados a ListBucket, GetObject y PutObject.
- Acceso restringido al prefijo raw/.
- Rol IAM de auditoría con permisos de solo lectura.

### Backend remoto

- Bucket Amazon S3 para almacenar el estado de Terraform.
- Versionado habilitado.
- Cifrado SSE-S3.
- Acceso público bloqueado.
- Tabla DynamoDB para state locking.

## 4. Estructura del proyecto

    coderhouse-aws-infra/
    ├── modules/
    │   ├── network/
    │   │   ├── main.tf
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   └── identity/
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    ├── environments/
    │   └── dev/
    │       ├── main.tf
    │       ├── variables.tf
    │       ├── provider.tf
    │       ├── backend.tf
    │       └── outputs.tf
    ├── evidences/
    │   └── terraform-plan.png
    ├── README.md
    ├── PLAN_OUTPUT.md
    └── .gitignore

## 5. Requisitos previos

Para reproducir el proyecto se necesita:

- Una cuenta AWS con permisos adecuados.
- Terraform instalado.
- AWS CLI instalado y autenticado.
- Git instalado.

Antes de inicializar Terraform se deben crear:

1. Un bucket S3 para el backend remoto.
2. Una tabla DynamoDB llamada coderhouse-tf-lock, con clave de partición LockID de tipo String.

El bucket debe tener versionado, cifrado SSE-S3 y acceso público bloqueado.

Se debe actualizar backend.tf con el nombre del bucket y configurar un perfil AWS con credenciales válidas para Terraform.

## 6. Despliegue de infraestructura

Ingresar al entorno de desarrollo:

    cd environments/dev

Inicializar Terraform:

    terraform init

Validar la configuración:

    terraform validate

Visualizar los recursos planificados:

    terraform plan

Desplegar la infraestructura:

    terraform apply

Revisar los cambios y los posibles costos antes de confirmar el despliegue.

## 7. Outputs

Terraform proporciona las siguientes salidas:

- vpc_id
- private_subnet_ids
- data_execution_role_arn
- audit_role_arn

Para consultarlas:

    terraform output

## 8. Seguridad

- Usuario IAM dedicado para Terraform.
- Autenticación multifactor (MFA).
- Credenciales temporales.
- Políticas IAM con permisos específicos.
- Subredes sin acceso directo a Internet.
- Backend remoto cifrado.
- Archivos sensibles excluidos mediante .gitignore.

## 9. Consideraciones

La infraestructura fue desarrollada en la región us-east-2 (Ohio).

El bucket de estado y la tabla DynamoDB se crearon previamente y no están gestionados por los módulos Terraform.

El state locking mediante DynamoDB se utiliza para cumplir con la consigna, aunque está obsoleto en versiones recientes de Terraform.

El rol de procesamiento referencia un futuro bucket de datos que todavía no se despliega.

Los servicios de AWS pueden generar costos según su utilización.

## 10. Evidencias

El resultado exitoso de terraform plan se encuentra documentado en PLAN_OUTPUT.md.

Resultado obtenido:

    Plan: 11 to add, 0 to change, 0 to destroy.

La infraestructura fue desplegada exitosamente mediante terraform apply.
