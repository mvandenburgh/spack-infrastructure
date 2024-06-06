# Generated by Django 4.2.4 on 2024-05-31 17:36

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("core", "0014_dimensional_models"),
    ]

    operations = [
        migrations.CreateModel(
            name="TimerDataDimension",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("cache", models.BooleanField()),
            ],
        ),
        migrations.CreateModel(
            name="TimerFact",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("total_duration", models.FloatField()),
            ],
        ),
        migrations.CreateModel(
            name="TimerPhaseDimension",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("path", models.CharField(max_length=64, unique=True)),
                ("is_subphase", models.BooleanField()),
            ],
        ),
        migrations.CreateModel(
            name="TimerPhaseFact",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("duration", models.FloatField()),
                (
                    "ratio_of_total",
                    models.FloatField(
                        help_text="The fraction of the timer total that this phase contributes to."
                    ),
                ),
            ],
        ),
        migrations.AddField(
            model_name="timerphasefact",
            name="date",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT, to="core.datedimension"
            ),
        ),
        migrations.AddField(
            model_name="timerphasefact",
            name="job",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT, to="core.jobdatadimension"
            ),
        ),
        migrations.AddField(
            model_name="timerphasefact",
            name="package",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT, to="core.packagedimension"
            ),
        ),
        migrations.AddField(
            model_name="timerphasefact",
            name="spec",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT,
                to="core.packagespecdimension",
            ),
        ),
        migrations.AddField(
            model_name="timerphasefact",
            name="phase",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT,
                to="core.timerphasedimension",
            ),
        ),
        migrations.AddField(
            model_name="timerphasefact",
            name="time",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT, to="core.timedimension"
            ),
        ),
        migrations.AddField(
            model_name="timerphasefact",
            name="timer_data",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT,
                to="core.timerdatadimension",
            ),
        ),
        migrations.AddConstraint(
            model_name="timerphasedimension",
            constraint=models.CheckConstraint(
                check=models.Q(
                    models.Q(("is_subphase", True), ("path__contains", "/")),
                    models.Q(
                        ("is_subphase", False),
                        models.Q(("path__contains", "/"), _negated=True),
                    ),
                    _connector="OR",
                ),
                name="consistent-subphase-path",
            ),
        ),
        migrations.AddField(
            model_name="timerfact",
            name="date",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT, to="core.datedimension"
            ),
        ),
        migrations.AddField(
            model_name="timerfact",
            name="job",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT, to="core.jobdatadimension"
            ),
        ),
        migrations.AddField(
            model_name="timerfact",
            name="package",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT, to="core.packagedimension"
            ),
        ),
        migrations.AddField(
            model_name="timerfact",
            name="spec",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT,
                to="core.packagespecdimension",
            ),
        ),
        migrations.AddField(
            model_name="timerfact",
            name="time",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT, to="core.timedimension"
            ),
        ),
        migrations.AddField(
            model_name="timerfact",
            name="timer_data",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT,
                to="core.timerdatadimension",
            ),
        ),
        migrations.AlterUniqueTogether(
            name="timerdatadimension",
            unique_together={("cache",)},
        ),
        migrations.AddConstraint(
            model_name="timerfact",
            constraint=models.UniqueConstraint(
                fields=("job", "date", "time", "timer_data", "package", "spec"),
                name="timer-fact-composite-key",
            ),
        ),
        migrations.AddConstraint(
            model_name="timerphasefact",
            constraint=models.UniqueConstraint(
                fields=(
                    "job",
                    "date",
                    "time",
                    "timer_data",
                    "package",
                    "spec",
                    "phase",
                ),
                name="timerphase-fact-composite-key",
            ),
        ),
    ]
