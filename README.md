# Infraestructura base AWS con Terraform

Proyecto de Ingeniería de Datos en AWS de Coderhouse. Implementa infraestructura modular mediante Terraform para preparar la Pre-entrega 2: ingesta real-time sobre el entorno base.

La Fase 1 incluye Network, Identity y Storage, con backend remoto S3 y DynamoDB. Kinesis Data Streams, Amazon Data Firehose, productores Python y alarmas CloudWatch todavía no están implementados.

## Configuración

- Entorno: `dev`.
- Región: `us-east-2` (Ohio).
- Rama de trabajo: `feature/ingesta-kinesis`.
- Terraform: `>= 1.5.0`.
- Proveedor: `hashicorp/aws ~> 6.0` (versión fijada en `.terraform.lock.hcl`).

## Arquitectura actual

### Network

- VPC con CIDR predeterminado `10.0.0.0/16` y DNS habilitado.
- Dos subredes privadas en distintas zonas de disponibilidad, sin asignación de IP pública.
- Una tabla de rutas privada con sus asociaciones.
- Un endpoint Gateway de S3 asociado a esa tabla.
- Sin Internet Gateway ni NAT Gateway definidos en el módulo.

### Identity

- Rol de ejecución que permite a AWS Lambda asumirlo.
- Política S3 con `ListBucket`, `GetObject` y `PutObject`, restringida al prefijo `raw/` del bucket de datos.
- Rol de auditoría con lectura de configuración de red, roles del proyecto y configuración del bucket de estado.

DEV entrega `module.storage.data_bucket_name` a Identity. La integración conserva las políticas y la restricción a `raw/`; no concede acceso a Bronze ni permisos para Firehose.

### Storage

El módulo `modules/storage` define:

| Recurso | Configuración |
|---|---|
| `aws_s3_bucket.data` | Bucket del Data Lake |
| `aws_s3_bucket_server_side_encryption_configuration.data` | Cifrado predeterminado SSE-S3 con `AES256` |
| `aws_s3_bucket_public_access_block.data` | Las cuatro opciones de bloqueo público habilitadas |
| `aws_s3_bucket_ownership_controls.data` | `BucketOwnerEnforced`: ACL deshabilitadas y propiedad del dueño del bucket |

Las etiquetas del bucket son `Name` (nombre del bucket), `Environment` (entorno), `Project = coderhouse-data-engineering` y `ManagedBy = Terraform`.

El bucket queda privado por defecto. Este módulo no define versionado, reglas de ciclo de vida ni una política de bucket adicional.

Variables del módulo:

| Variable | Tipo | Valor predeterminado |
|---|---|---|
| `environment` | `string` | Sin valor; obligatoria |
| `data_bucket_name` | `string`, no admite `null` | Sin valor; obligatoria |

En DEV, `data_bucket_name` es una variable opcional con valor predeterminado `null`. Cuando no se proporciona, se construye `coderhouse-data-<account_id>` usando `data.aws_caller_identity.current.account_id`. Puede establecerse un nombre alternativo globalmente único si existe un conflicto de disponibilidad S3; no se escribe manualmente el identificador de cuenta en el código del módulo.

Storage expone `data_bucket_name`, `data_bucket_arn` y `data_bucket_id` (en S3, el ID coincide con el nombre). DEV también publica esas tres salidas.

El bucket será el destino de la futura capa Bronze:

```text
bronze/ingesta/year=YYYY/month=MM/day=DD/
```

Estos prefijos serán generados posteriormente por Firehose, cuando se configure la entrega y sus permisos. No es necesario crear carpetas manualmente y no se cargaron objetos mediante este módulo.

### Backend remoto y separación de buckets

| Uso | Bucket | Gestión |
|---|---|---|
| Estado de Terraform | `coderhouse-tfstate-925213028629` | Preexistente; configurado en `enviroments/dev/backend.tf` |
| Data Lake | `coderhouse-data-925213028629` | Gestionado por `module.storage` |

El backend usa la clave `dev/terraform.tfstate`, región `us-east-2`, cifrado y la tabla DynamoDB `coderhouse-tf-lock` para bloqueo. El bucket de estado y la tabla se crearon previamente y no están gestionados por estos módulos. La documentación del primer entregable registra versionado, SSE-S3 y bloqueo público para el bucket de estado; el backend no configura esas propiedades.

El bucket de estado se reserva exclusivamente para Terraform. Los eventos de ingesta se almacenarán en el Data Lake.

## Estructura del repositorio

```text
coderhouse-aws-infra/
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── identity/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── storage/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── enviroments/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── provider.tf
│       ├── backend.tf
│       ├── outputs.tf
│       └── .terraform.lock.hcl
├── evidences/
│   └── terraform-plan.png
├── README.md
├── PLAN_OUTPUT.md
├── .gitattributes
└── .gitignore
```

Se conserva el nombre real `enviroments/dev`.

## Requisitos y despliegue

Se necesitan Terraform, Git y credenciales AWS válidas para el perfil configurado localmente. El flujo de autenticación puede utilizar AWS CLI. El bucket de backend y la tabla DynamoDB con clave de partición `LockID` de tipo `String` deben existir antes de inicializar Terraform; en este entorno ya están disponibles.

Los siguientes comandos son una guía de despliegue; no se ejecutaron durante el bloque de documentación. Ejecutarlos desde `enviroments/dev`, revisando el plan y los costos antes de aprobar un despliegue:

```bash
cd enviroments/dev
terraform init
terraform validate
terraform plan
terraform apply
terraform output
```

`init` inicializa backend y proveedores; `validate` comprueba la configuración; `plan` muestra los cambios; `apply` despliega los cambios aprobados; `output` consulta las salidas.

## Outputs de DEV

| Output | Contenido |
|---|---|
| `vpc_id` | ID de la VPC |
| `private_subnet_ids` | IDs de las subredes privadas |
| `data_execution_role_arn` | ARN del rol de ejecución Lambda |
| `audit_role_arn` | ARN del rol de auditoría |
| `data_bucket_name` | Nombre del bucket del Data Lake |
| `data_bucket_arn` | ARN del bucket del Data Lake |
| `data_bucket_id` | ID del bucket del Data Lake |

## Seguridad

- Las credenciales locales utilizadas por Terraform autentican al operador que administra infraestructura. Deben mantenerse fuera del repositorio; la documentación inicial contempla MFA y credenciales temporales.
- Los roles IAM de los servicios son identidades distintas. El rol Lambda actual conserva acceso únicamente a `raw/`; la futura entrega Firehose requerirá su configuración de identidad y permisos.
- La identidad de despliegue necesita permisos para crear y consultar el bucket y administrar su cifrado, bloqueo público, propiedad y etiquetas, además del acceso al backend. Durante el despliegue se corrigieron permisos IAM de operaciones S3, según confirmó el usuario; esos permisos administrativos no se agregaron al rol Lambda.
- El almacenamiento privado se implementa con bloqueo público completo, ACL deshabilitadas y cifrado SSE-S3. Las subredes privadas acceden a S3 mediante el endpoint Gateway.
- Los estados, planes guardados, variables sensibles, credenciales y temporales se excluyen con `.gitignore`. `.terraform.lock.hcl` se conserva versionado. No adjuntar secretos ni salidas sin revisar su contenido.

## Estado y evidencias

El primer entregable incluye Network e Identity. Su plan histórico mostró `Plan: 11 to add, 0 to change, 0 to destroy.`; esa cifra corresponde al plan inicial, no al último despliegue.

Al cierre de la Fase 1, el usuario confirmó el despliegue del bucket del Data Lake, región, SSE-S3, bloqueo público, propiedad y etiquetas; la disponibilidad del backend; un plan final con `No changes` y los outputs correctos. También confirmó que se resolvieron los permisos S3 y se retiró la marca `tainted` del bucket después de verificar su existencia.

[PLAN_OUTPUT.md](PLAN_OUTPUT.md) conserva la evidencia histórica y distingue las confirmaciones del usuario de las salidas textuales pendientes de adjuntar. La captura existente `evidences/terraform-plan.png` corresponde al primer entregable.

La Fase 2 queda pendiente de autorización e incluirá Kinesis Data Streams y Amazon Data Firehose. Los servicios AWS pueden generar costos.
