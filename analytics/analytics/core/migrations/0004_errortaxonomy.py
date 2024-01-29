# Generated by Django 4.2.4 on 2024-01-05 17:02

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("core", "0003_job_arch_job_build_jobs_job_compiler_name_and_more"),
    ]

    operations = [
        migrations.CreateModel(
            name="ErrorTaxonomy",
            fields=[
                (
                    "job_id",
                    models.PositiveBigIntegerField(primary_key=True, serialize=False),
                ),
                ("created", models.DateTimeField(auto_now_add=True)),
                ("attempt_number", models.PositiveSmallIntegerField()),
                ("retried", models.BooleanField()),
                ("error_taxonomy", models.CharField(max_length=64)),
                ("error_taxonomy_version", models.CharField(max_length=32)),
                (
                    "webhook_payload",
                    models.JSONField(
                        help_text="The JSON payload received from the GitLab job webhook."
                    ),
                ),
            ],
        ),
    ]
