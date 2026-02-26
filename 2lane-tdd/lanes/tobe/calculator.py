"""
Calculator implementation (TO-BE version).
Refactored with better architecture, history tracking, and validation.
"""

class Calculator:
    """Calculator class with history tracking"""

    def __init__(self):
        self.history = []

    def _record_operation(self, operation, a, b, result):
        """Record operation to history"""
        self.history.append({
            "operation": operation,
            "operands": (a, b),
            "result": result
        })

    def add(self, a, b):
        """Add two numbers"""
        result = a + b
        self._record_operation("add", a, b, result)
        return result

    def subtract(self, a, b):
        """Subtract two numbers"""
        result = a - b
        self._record_operation("subtract", a, b, result)
        return result

    def multiply(self, a, b):
        """Multiply two numbers"""
        result = a * b
        self._record_operation("multiply", a, b, result)
        return result

    def divide(self, a, b):
        """Divide two numbers"""
        if b == 0:
            raise ZeroDivisionError("Cannot divide by zero")
        result = a / b
        self._record_operation("divide", a, b, result)
        return result

    def get_history(self):
        """Get operation history"""
        return self.history.copy()

    def clear_history(self):
        """Clear operation history"""
        self.history.clear()


# Global calculator instance for backward compatibility
_default_calculator = Calculator()


def add(a, b):
    """Add two numbers (wrapper for backward compatibility)"""
    return _default_calculator.add(a, b)


def subtract(a, b):
    """Subtract two numbers (wrapper for backward compatibility)"""
    return _default_calculator.subtract(a, b)


def multiply(a, b):
    """Multiply two numbers (wrapper for backward compatibility)"""
    return _default_calculator.multiply(a, b)


def divide(a, b):
    """Divide two numbers (wrapper for backward compatibility)"""
    return _default_calculator.divide(a, b)


def get_calculator():
    """Get the default calculator instance"""
    return _default_calculator


def new_calculator():
    """Create a new calculator instance"""
    return Calculator()
