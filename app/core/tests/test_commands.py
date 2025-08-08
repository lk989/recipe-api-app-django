"""
Test custom Django management commands.
"""

from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


# Mock the check method to simulate database availability
# check is a method in the Command class that checks
@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):
    """Test commands."""

    def test_wait_for_db_ready(self, patched_checkc):
        """Test waiting for database when database is available."""
        patched_checkc.return_value = True

        call_command('wait_for_db')

        patched_checkc.assert_called_once_with(databases=['default'])

    # arguments should be put from the inside out.
    # like here: sleep before check
    @patch('time.sleep')
    def test_for_db_delay(self, patched_sleep, patched_checkc):
        """Test waiting for database when database is not available."""
        # Simulate the database being unavailable for a few checks
        # side_effect allows us to specify a sequence of return values
        patched_checkc.side_effect = [Psycopg2Error] * 2 + \
            [OperationalError] * 3 + [True]

        call_command('wait_for_db')

        self.assertEqual(patched_checkc.call_count, 6)
        patched_checkc.assert_called_with(databases=['default'])
