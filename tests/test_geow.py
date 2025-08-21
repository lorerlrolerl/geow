"""Basic tests for the geow package."""

from geow import __version__


def test_version():
    """Test that version is defined."""
    assert __version__ is not None
    assert isinstance(__version__, str)
    assert __version__ == "0.0.0"


def test_package_import():
    """Test that the package can be imported."""
    import geow

    assert geow is not None
