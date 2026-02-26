"""
Contract tests for Calculator functionality.
MUST PASS in both AS-IS and TO-BE lanes.
"""

import pytest
from calculator import add, subtract, multiply, divide


def test_add_two_positive_numbers():
    """Add two positive numbers"""
    result = add(2, 3)
    assert result == 5


def test_add_negative_numbers():
    """Add two negative numbers"""
    result = add(-1, -2)
    assert result == -3


def test_add_zero():
    """Add zero to a number"""
    result = add(5, 0)
    assert result == 5


def test_subtract():
    """Subtract two numbers"""
    result = subtract(10, 3)
    assert result == 7


def test_subtract_negative():
    """Subtract negative number"""
    result = subtract(5, -3)
    assert result == 8


def test_multiply():
    """Multiply two numbers"""
    result = multiply(4, 5)
    assert result == 20


def test_multiply_negative():
    """Multiply by negative"""
    result = multiply(3, -2)
    assert result == -6


def test_multiply_zero():
    """Multiply by zero"""
    result = multiply(100, 0)
    assert result == 0


def test_divide():
    """Divide two numbers"""
    result = divide(10, 2)
    assert result == 5.0


def test_divide_float():
    """Divide with floating point result"""
    result = divide(1, 3)
    assert result == pytest.approx(0.333, abs=0.001)


def test_divide_by_zero():
    """Divide by zero should raise error"""
    with pytest.raises(ZeroDivisionError):
        divide(10, 0)


def test_divide_negative():
    """Divide negative numbers"""
    result = divide(-10, 2)
    assert result == -5.0


def test_calculator_chain():
    """Test chained operations"""
    result = add(multiply(2, 3), subtract(10, 5))
    assert result == 11  # (2*3) + (10-5) = 6 + 5 = 11
