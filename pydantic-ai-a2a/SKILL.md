---
name: pydantic-ai-a2a
description: >-
  Build A2A-enabled agents with PydanticAI and FastA2A. Use when the user asks
  to create multi-agent systems, A2A servers, agent delegation, programmatic
  agent hand-off, or inter-agent communication using Pydantic AI.
---

# PydanticAI A2A Agents

## Installation

```bash
# Core + A2A support
pip install 'pydantic-ai-slim[a2a]'
# or
uv add 'pydantic-ai-slim[a2a]'
```

This installs `fasta2a` (Starlette-based A2A server) alongside `pydantic-ai`.

## Expose an Agent as an A2A Server

The simplest path: call `to_a2a()` on any PydanticAI agent.

```python
from pydantic_ai import Agent

agent = Agent(instructions='You are a helpful research assistant.')
app = agent.to_a2a()
```

Run with any ASGI server:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

`to_a2a()` accepts the same arguments as the `FastA2A` constructor.

### What `to_a2a()` handles automatically

- Stores complete conversation history (including tool calls) in context storage
- Maintains conversation continuity via `context_id` across multiple tasks
- Persists agent results as A2A artifacts:
  - String results become `TextPart` artifacts
  - Structured data (BaseModel, dataclass, etc.) become `DataPart` artifacts wrapped as `{"result": ...}`
  - Artifacts include metadata with type info and JSON schema when available

## FastA2A Architecture

FastA2A is framework-agnostic. As a developer, you provide three components:

- **Storage**: saves/loads tasks and stores conversation context
- **Broker**: schedules tasks for execution
- **Worker**: executes tasks (your agent logic)

### Tasks vs Context

- **Task**: One complete agent execution. Client sends a message, a task is created, the agent runs to completion, and output is stored as a task artifact.
- **Context**: A conversation thread spanning multiple tasks. Linked by `context_id`. All tasks sharing a `context_id` share full message history.

## Agent Delegation (Tool-based)

One agent delegates to another via a tool, then regains control. Agents are stateless and global--no need to include them in dependencies.

```python
from pydantic_ai import Agent, RunContext, UsageLimits

parent_agent = Agent(
    instructions=(
        'Use the `delegate_task` tool to get specialized analysis, '
        'then synthesize the results.'
    ),
)

specialist_agent = Agent(output_type=list[str])

@parent_agent.tool
async def delegate_task(ctx: RunContext[None], query: str) -> list[str]:
    r = await specialist_agent.run(
        query,
        usage=ctx.usage,
    )
    return r.output

result = parent_agent.run_sync(
    'Analyze this data.',
    usage_limits=UsageLimits(request_limit=10, total_tokens_limit=5000),
)
```

**Critical patterns:**
- Pass `usage=ctx.usage` to the delegate so token counts roll up to the parent's `result.usage()`.
- Use `UsageLimits` (with `request_limit`, `total_tokens_limit`, `tool_calls_limit`) to prevent runaway loops.
- Different agents can use different models. When mixing models, monetary cost calculation from `result.usage()` won't be possible, but `UsageLimits` still works.

### Forwarding Dependencies

When delegate agents need the same deps as the parent, forward `ctx.deps`:

```python
from dataclasses import dataclass
import httpx
from pydantic_ai import Agent, RunContext

@dataclass
class Deps:
    http_client: httpx.AsyncClient
    api_key: str

parent_agent = Agent(
    deps_type=Deps,
    instructions='Use the search tool to find information.',
)

search_agent = Agent(
    deps_type=Deps,
    output_type=list[str],
)

@parent_agent.tool
async def search(ctx: RunContext[Deps], query: str) -> list[str]:
    r = await search_agent.run(
        query,
        deps=ctx.deps,
        usage=ctx.usage,
    )
    return r.output

@search_agent.tool
async def web_search(ctx: RunContext[Deps], query: str) -> str:
    response = await ctx.deps.http_client.get(
        'https://api.example.com/search',
        params={'q': query},
        headers={'Authorization': f'Bearer {ctx.deps.api_key}'},
    )
    response.raise_for_status()
    return response.text
```

## Programmatic Agent Hand-off

Multiple agents called in succession by application code. Agents don't need to share deps. Use `message_history` for multi-turn conversations within each agent.

```python
from pydantic import BaseModel
from pydantic_ai import Agent, ModelMessage, RunUsage, UsageLimits

class AnalysisResult(BaseModel):
    findings: list[str]

class Failed(BaseModel):
    """Unable to complete the task."""

analysis_agent = Agent(
    output_type=AnalysisResult | Failed,  # type: ignore
    instructions='Analyze the provided data.',
)

summary_agent = Agent(
    instructions='Summarize the analysis into a brief report.',
)

usage_limits = UsageLimits(request_limit=15)

async def run_pipeline(user_input: str):
    usage = RunUsage()

    analysis_result = await analysis_agent.run(
        user_input,
        usage=usage,
        usage_limits=usage_limits,
    )

    if isinstance(analysis_result.output, Failed):
        return None

    summary_result = await summary_agent.run(
        f'Summarize these findings: {analysis_result.output.findings}',
        usage=usage,
        usage_limits=usage_limits,
    )
    return summary_result.output
```

### Retry with message history

To retry or continue a conversation with an agent, pass back the message history:

```python
result = await agent.run(prompt, message_history=message_history)
if isinstance(result.output, Failed):
    message_history = result.all_messages(
        output_tool_return_content='Please try again.'
    )
    # loop and re-run with updated message_history
```

## Output Types

Use union types to let the agent signal success or failure:

```python
class Success(BaseModel):
    data: str

class Failed(BaseModel):
    """Unable to complete the task."""

agent = Agent(output_type=Success | Failed)  # type: ignore
```

Each union member is registered as a separate tool internally. Use `isinstance()` to branch on the result.

## Observability

Instrument multi-agent systems with Logfire for full tracing:

```python
import logfire

logfire.configure()
logfire.instrument_pydantic_ai()
```

This traces delegation decisions, per-agent latency, token usage, and tool call internals across the entire agent graph.

## API Quick Reference

| Concept | API |
|---|---|
| Define agent | `Agent(instructions=..., output_type=..., deps_type=...)` |
| Run agent | `await agent.run(prompt)` or `agent.run_sync(prompt)` |
| Get output | `result.output` |
| Get usage | `result.usage()` |
| Expose as A2A | `agent.to_a2a()` |
| Define tool | `@agent.tool` on an `async def(ctx: RunContext[Deps], ...) -> ...` |
| Forward usage | `await delegate.run(prompt, usage=ctx.usage)` |
| Forward deps | `await delegate.run(prompt, deps=ctx.deps)` |
| Limit usage | `UsageLimits(request_limit=N, total_tokens_limit=N, tool_calls_limit=N)` |
| Message history | `result.all_messages()` / pass as `message_history=` |
