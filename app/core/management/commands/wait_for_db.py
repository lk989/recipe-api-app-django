"""
    Django command to wait for the database to be available.
"""

form django.core.management.base import BaseCommand

class Command(BaseCommand):
    """Django command to wait for the database to be available."""

    def handle(self, *args, **options):
        """Handle the command."""
        pass