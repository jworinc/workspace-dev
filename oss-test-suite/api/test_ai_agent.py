import os
import pytest
from langchain.agents import initialize_agent, Tool
from langchain.agents import AgentType
from langchain.chat_models import ChatOpenAI

# Configuration for Local VibeProxy
BASE_URL = "http://localhost:8318/v1"
API_KEY = "local-token"
MODEL = "zai/glm-4.7"

class APITester:
    def __init__(self):
        self.llm = ChatOpenAI(
            openai_api_base=BASE_URL,
            openai_api_key=API_KEY,
            model_name=MODEL,
            temperature=0
        )
        
    def plan_test(self, endpoint_desc: str):
        """Generates a test plan based on endpoint description."""
        prompt = f"Plan a comprehensive test for this API endpoint: {endpoint_desc}. Include edge cases and validation steps."
        return self.llm.predict(prompt)

@pytest.fixture
def tester():
    return APITester()

def test_ai_generated_plan(tester):
    # Example: Testing the Mission Control health endpoint
    desc = "GET http://localhost:8000/api/v1/health"
    plan = tester.plan_test(desc)
    assert "status" in plan.lower()
    print(f"\nAI Test Plan:\n{plan}")
