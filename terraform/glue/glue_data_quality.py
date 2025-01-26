import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsgluedq.transforms import EvaluateDataQuality

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Script generated for node AWS Glue Data Catalog
AWSGlueDataCatalog_node1736981826603 = glueContext.create_dynamic_frame.from_catalog(database="metadata_repository", table_name="raw_prd_5201201", transformation_ctx="AWSGlueDataCatalog_node1736981826603")

# Script generated for node Evaluate Data Quality
EvaluateDataQuality_node1736981880298_ruleset = """
    # Example rules: Completeness "colA" between 0.4 and 0.8, ColumnCount > 10
    Rules = [
        RowCount > 0,
        ColumnCount = 17,
        IsComplete "subject"
    ]
"""

EvaluateDataQuality_node1736981880298 = EvaluateDataQuality().process_rows(frame=AWSGlueDataCatalog_node1736981826603, ruleset=EvaluateDataQuality_node1736981880298_ruleset, publishing_options={"dataQualityEvaluationContext": "EvaluateDataQuality_node1736981880298", "enableDataQualityCloudWatchMetrics": True, "enableDataQualityResultsPublishing": True, "resultsS3Prefix": "s3://raw-prd-5201201"}, additional_options={"observations.scope":"ALL","performanceTuning.caching":"CACHE_NOTHING"})

assert EvaluateDataQuality_node1736981880298[EvaluateDataQuality.DATA_QUALITY_RULE_OUTCOMES_KEY].filter(lambda x: x["Outcome"] == "Failed").count() == 0, "The job failed due to failing DQ rules for node: AWSGlueDataCatalog_node1736981826603"

job.commit()