# Databricks Under the Hood: Pipelines, Jobs, APIs, and Compute

## Overview

Beyond the lakehouse concept, day-to-day work on Databricks revolves around four practical layers: how data moves through pipelines, how jobs get scheduled and queued, how systems talk to Databricks programmatically through APIs, and how compute resources are provisioned and billed. Understanding these layers matters for anyone designing a production data or ML workload on the platform, since each one has direct cost and reliability implications.

## Data Pipelines: Delta Live Tables (DLT)

Delta Live Tables is Databricks' framework for building and managing data pipelines declaratively. Instead of writing manual orchestration logic, engineers define transformations as a series of tables and Delta Live Tables figures out the execution order, dependency graph, and incremental processing automatically.

- Supports both **batch** and **streaming** pipelines using the same syntax, so a pipeline can be prototyped in batch and later switched to streaming with minimal rewrites.
- Built-in **data quality expectations**: rules that flag, drop, or fail records that don't meet defined constraints, with pipeline-level metrics on how many records violated each rule.
- Automatic **schema evolution handling**, reducing the manual maintenance burden when upstream source schemas change.
- Typical pipeline structure follows the medallion architecture: raw data lands in a **Bronze** layer, cleaned and conformed data moves to **Silver**, and business-level aggregated data lands in **Gold** for consumption by BI tools and downstream applications.

## Job Scheduling and Queuing

Databricks Jobs is the orchestration layer for running notebooks, scripts, SQL queries, and DLT pipelines on a schedule or trigger.

- Jobs can be triggered on a **cron schedule**, by **file arrival** in cloud storage, or via **API call** from an external orchestrator.
- Each job can contain multiple **tasks** with defined dependencies, forming a directed acyclic graph (DAG), so downstream tasks only run once their upstream dependencies succeed.
- When compute capacity is constrained, queued jobs wait in a **job queue** and are dispatched once cluster capacity frees up; job queuing can be enabled or disabled per workspace, and queued runs are visually distinguished from running or failed runs in the Jobs UI.
- **Retry policies** can be set per task, including exponential backoff, so transient failures (like a brief network blip to a source system) don't require manual intervention.
- Job clusters can be configured to spin up fresh for each run and terminate afterward, which avoids paying for idle compute between scheduled runs, at the cost of a short cluster startup delay (commonly 3 to 7 minutes depending on cluster size and cloud).

## Compute Options

Databricks separates compute from storage, and offers several compute types depending on the workload:

| Compute Type | Typical Use | Billing Model |
|---|---|---|
| All-purpose clusters | Interactive notebook development, ad hoc exploration | Billed while running, including idle time unless auto-terminate is set |
| Job clusters | Scheduled production jobs and pipelines | Billed only for the duration of the job run |
| SQL warehouses | BI dashboards and SQL analytics queries | Serverless or classic; scales up/down based on query load |
| Serverless compute | Notebooks and jobs without manual cluster configuration | Pay-per-use, no cluster management required |

Autoscaling is available on most compute types, allowing a cluster to add or remove worker nodes automatically based on current load, within a configured minimum and maximum node count.

## APIs and Programmatic Access

Nearly everything doable in the Databricks UI can also be done through its REST APIs, which is what allows Databricks to be embedded into broader CI/CD and orchestration ecosystems rather than used only interactively.

- **Jobs API** — create, update, trigger, and monitor job runs programmatically, commonly used to kick off Databricks jobs from an external orchestrator like Airflow or Azure Data Factory.
- **Clusters API** — provision, resize, and terminate compute clusters, useful for infrastructure-as-code setups where cluster configs are version-controlled.
- **Unity Catalog API** — manage permissions, table metadata, and lineage information programmatically, supporting automated governance workflows.
- **SQL Statement Execution API** — run SQL queries against SQL warehouses and retrieve results without opening a notebook, often used to integrate Databricks query results into external applications.
- Most teams interact with these APIs through the **Databricks CLI** or the **Databricks Terraform provider**, rather than calling REST endpoints directly, to keep configuration reproducible and version-controlled.

## Data Lake Storage Layer

Underneath all of the above sits the data lake itself: raw files stored in open formats (primarily Parquet, wrapped by Delta Lake's transaction log) in cloud object storage such as S3, ADLS Gen2, or GCS.

- Storage and compute are billed and scaled **independently**, so storage costs stay low even as compute needs fluctuate.
- Delta Lake's transaction log enables **time travel**, letting a query reference the state of a table as of a previous version or timestamp, which is useful for debugging, auditing, or recovering from a bad write.
- **Z-ordering** and **liquid clustering** are optimization techniques that physically organize data on disk to speed up queries that filter on specific columns, reducing the amount of data scanned per query.
- **Auto Loader** incrementally and efficiently processes new files as they land in cloud storage, avoiding the need to rescan an entire directory on every pipeline run.

## Putting It Together: A Typical Production Flow

1. Raw data lands in cloud storage and is picked up incrementally by **Auto Loader**.
2. A **Delta Live Tables** pipeline processes it through Bronze, Silver, and Gold layers, applying data quality checks along the way.
3. The pipeline runs on a schedule via **Databricks Jobs**, using a job cluster that spins up for the run and terminates afterward.
4. Downstream, a **SQL warehouse** serves BI dashboards directly off the Gold tables.
5. **Unity Catalog** governs access across every layer, and the **Jobs API** allows an external orchestrator to trigger and monitor the entire flow as part of a larger cross-system pipeline.
