# Templates for LLM Self-Improvement: A Design Document

## The Motivation: Why We Need This

We've all been there. You ask an LLM to write an email:

**You:** "Write an email to my team about the product launch delay"  
**LLM:** "Dear Team, I hope this email finds you well. I am writing to inform you about..."  
**You:** "Too formal. Make it more casual."  
**LLM:** "Hey team! Just wanted to give you a heads up..."  
**You:** "Not that casual. And add urgency."  
**LLM:** "Hi everyone, I need to share an important update..."  
**You:** "Better, but mention the client impact and..."  
*[10 more iterations later]*  
**You:** [Exhausted] "I'll just write it myself."

## The Core Problem

Every interaction resets to zero. The LLM has no memory of what worked before, what patterns succeeded, or what communication strategies proved effective. From an information theory perspective, we're discarding valuable feedback signals after every use.

This creates an absurd situation: despite processing millions of interactions, LLMs never improve at the tasks they do most. The model remains static while the world - and user needs - evolve around it.

## The Insight: You Can't Optimize What You Don't Standardize

It's a fundamental principle of machine learning: without consistent inputs, you cannot measure improvement. When every prompt is ad-hoc, every interaction is an independent trial with no learning transfer.

The solution isn't to make the model larger or add more training data. It's to create a learning framework at the interface layer - where variation and selection can operate.

## Why Templates, Not More Complex Solutions?

The field has proposed many solutions to help LLMs handle long-duration tasks:

- **Multi-agent systems**: Multiple specialized LLMs coordinating together
- **External memory**: Vector databases storing every interaction
- **Continual learning**: Updating model weights over time
- **Cognitive architectures**: Complex memory hierarchies mimicking human cognition

These approaches haven't worked well in practice. They sound impressive in research papers, but real-world implementations are plagued with reliability issues, coordination failures, and maintenance nightmares. 

## What Are We Actually Solving?

The problem isn't that LLMs are too small, too forgetful, or too isolated. The problem is that **LLMs don't learn from usage**. Every interaction resets to zero.

Templates solve this at the right layer - the interface - with the right mechanism - evolution through use.

## The Template Solution

Templates provide consistency through patterns, not memory through facts. Instead of random instructions, you create a reusable prompt that defines **HOW** to handle a task, while you provide **WHAT** the task is about:

### The Key Pattern: Structure + Context

Templates work best when they:
- **Define the structure** (format, style, approach)
- **Let users provide the context** (specific situation, details, requirements)

This separation is powerful because the structure rarely changes (how you write emails) while the context always changes (what the email is about).

```
/write_team_email{
  urgency: {urgency_level}
}

Write an email to my team about the situation I describe below.

Voice guidelines:
- Professional but approachable (think "smart colleague, not corporate robot")
- Get to the point in the first sentence
- Use "we" language for shared challenges
- Include clear next steps

My typical phrases:
- Start with "Hi team," (never "Dear" or "Hey")
- "I wanted to loop you in on..." for updates
- "Here's where we stand:" for status updates
- End with specific actions: "Please..." or "Could you..."

Example of my style:
"Hi team, I wanted to loop you in on the launch timeline change. Here's where we stand: 
we need an extra two weeks due to the security audit findings. This means our target 
date moves to March 15th. Please update your project plans accordingly and flag any 
client communications that need adjusting."

Urgency modifiers:
\if {urgency_level} == "high"
  - Add "Time-sensitive:" to subject
  - Include deadline in first sentence
  - Bold key dates
\elif {urgency_level} == "critical"
  - Start with "URGENT:"
  - First line: "Action needed by [date]"
  - Use red text for deadlines
\endif
```

Now you can simply invoke:
```
/write_team_email{urgency: "high"}
There was a delay in getting the supplies on time, so I need the entire team 
tomorrow at 8 am to discuss alternatives. The client deliverable is at risk.
```

The template provides the structure and style, while you provide the specific context. The LLM combines both to create an email that matches your voice AND conveys your exact message.

## Templates vs External Memory: The Key Difference

**External memory systems store facts:**
- "User John likes concise emails"
- "Last project used PostgreSQL"
- "Customer complained about response time"

**Templates store patterns:**
- "When {urgency} is high, put deadline in first sentence"
- "For {project_type} == 'startup', keep it simple"
- "If discussing {technical_topic}, include code example"

The difference is **compression through abstraction**. One template replaces thousands of similar interactions.

### The Cookbook Analogy

External memory is like recording every meal you've ever cooked. Templates are like writing down the recipe that worked.

When you want to cook again, which is more useful?

## Making It Self-Improving

### The Scale Problem: Why Self-Improvement Is Essential

Imagine running a company. The routine tasks are endless:

**Recruiting alone requires dozens of templates:**
- Job postings for engineers vs designers vs sales
- Initial candidate outreach (different tone for senior vs junior)
- Interview scheduling emails
- Rejection letters (with/without feedback)
- Offer letters (equity vs no equity, remote vs on-site)
- Reference check requests

**Then multiply across every business function:**
- **HR**: Onboarding flows, performance reviews, policy updates, exit interviews
- **Sales**: Cold outreach, follow-ups, proposals, contract negotiations
- **Customer Success**: Onboarding emails, check-ins, renewal notices, escalation responses
- **Finance**: Invoice reminders, expense rejections, budget approvals, vendor negotiations
- **Operations**: Meeting agendas, status updates, project kickoffs, deadline reminders
- **Legal**: NDA requests, contract reviews, compliance notices

That's easily thousands of templates for a mid-sized company.

### The Beautiful Possibility

Now imagine if every time someone used a template - every email sent, every document created, every message crafted - the system learned something.

What if templates could notice that:
- Your best salespeople always mention pricing transparency upfront
- Candidates respond 3x better when you lead with the technical challenge
- Customer complaints de-escalate faster with empathy in the first line
- Team updates get more engagement with a casual Friday tone

Templates are used hundreds of times per day across an organization. That's hundreds of learning opportunities currently wasted. What if we could capture that wisdom automatically?

### The Solution: Templates That Learn

Instead of templates being static files that slowly become outdated, they become living documents that evolve with every use. The LLM notices patterns in how you modify its outputs and automatically suggests improvements.

This transforms template management from a burden into an asset that gets better with every use.

## Example: Team Email Evolution Through Usage

**Initial template (basic):**
```
/write_team_email{urgency: {urgency_level}}
Write an email to my team about the situation I describe below.
```

**First use:**
```
You: /write_team_email{urgency: "high"}
There was a delay in getting the supplies on time, so I need the entire team 
tomorrow at 8 am to discuss alternatives. The client deliverable is at risk.

LLM: Hi team, I wanted to loop you in on an urgent supply chain issue. 
Here's where we stand: we've experienced a delay in getting supplies, putting 
our client deliverable at risk. Please join me tomorrow at 8 am to discuss 
alternatives...

You: Good, but add the zoom link and mention it's mandatory

LLM: Hi team, I wanted to loop you in on an urgent supply chain issue.
Here's where we stand: we've experienced a delay in getting supplies, putting 
our client deliverable at risk. 

Mandatory meeting tomorrow at 8 am to discuss alternatives.
Join: [Zoom link]

Please prioritize this - we need all hands to solve this quickly.

You: Perfect!
```

**After 50 similar uses across the team:**

The system notices patterns:
- 84% of urgent meetings include a Zoom link
- 91% specify mandatory vs optional attendance
- 76% include a brief agenda
- 88% mention impact/stakes when urgency is high
- Morning meetings often include "coffee/breakfast provided" note

**The template evolves automatically:**
```
/write_team_email{
  urgency: {low|medium|high|critical},
  meeting_details: {include_meeting}?  // auto-suggested when urgency >= high
}

Write an email to my team about the situation I describe below.

Voice guidelines:
- Professional but approachable 
- Get to the point in the first sentence
- Use "we" language for shared challenges
- Include clear next steps

\if {urgency} == "high" OR {urgency} == "critical"
  // Auto-learned: High urgency emails often involve meetings
  Suggested elements:
  - [ ] Meeting time/date mentioned?
  - [ ] Attendance requirement (mandatory/optional)?
  - [ ] Zoom/location details?
  - [ ] Brief agenda/purpose?
  - [ ] Stakes/impact clearly stated?
\endif

\if {meeting_details}
  // Auto-learned meeting patterns
  Meeting logistics to include:
  - Attendance: [Mandatory for all / Optional / Required for leads only]
  - Join: [Zoom link] / Location: [Conference room]
  - Duration: [Estimated time]
  
  \if {meeting_time} < "9am"
    - Coffee and breakfast will be provided  // learned from 89% of early meetings
  \endif
\endif

// Auto-learned urgency patterns
\if {urgency} == "critical"
  - Start with "URGENT:" in subject
  - First line must contain deadline/action needed
  - Include escalation path if unavailable
\endif
```

**The mechanism:** The template evolves through pattern detection in user modifications. When many users make similar changes, those changes become part of the template. It's unsupervised learning with human behavior as the training signal.

## How Automatic Reflection Works

The system tracks what users actually change in the generated output:

**Automatic reflection at conversation end:**
```
/reflect{
  template_used: "write_team_email",
  conversation_id: "conv_789"
}

REFLECTION OUTPUT:
Analysis of user modifications:

Added features:
- meeting_link (seen 84 times with high urgency)
- attendance_requirement (seen 91 times)
- specific_time (seen 100% with urgency=high)

Statistical patterns:
- P(meeting_link | urgency=high) = 0.84 (n=298)
- P(attendance_spec | urgency=high) = 0.91 (n=312)
- These additions correlate strongly (r=0.87)

Discovered rule:
When urgency ∈ {high, critical}, users consistently add:
- Meeting logistics (84% confidence)
- Attendance requirement (91% confidence)
- Impact statement (88% confidence)

Recommendation: Add conditional prompt for these elements
Evidence strength: HIGH (based on 84+ instances)
```

The system learns through simple pattern recognition - no complex fitness functions needed.

**The template evolves over time:**
```diff
/write_team_email{
  urgency: {urgency_level}
+ meeting_details: {include_meeting}  // learned: high urgency often = meeting
}

- Write an email to my team about the situation I describe below.
+ Write an email to my team about the situation I describe below.
+ 
+ // Patterns learned from 200+ uses:
+ \if {urgency} == "high" OR {urgency} == "critical"
+   Suggested elements:
+   - [ ] Meeting time/date mentioned?
+   - [ ] Attendance requirement?
+   - [ ] Zoom/location details?
+   - [ ] Stakes clearly stated?
+ \endif
+ 
+ \if {meeting_details}
+   Meeting logistics:
+   - Attendance: [Mandatory/Optional]
+   - Join: [Zoom link]
+   - Duration: [Estimated time]
+ \endif
```

This evolution happened automatically through usage, not manual updates.

## The Compound Effect: Evolutionary Fitness at Scale

From an information theory perspective, templates are discovering optimal compression algorithms for human-AI communication:

- **Signal extraction**: Templates learn to preserve high-information content (deadlines, requirements) while eliminating noise (pleasantries, filler words)
- **Pattern compression**: Recurring structures (meeting logistics, action items) get encoded into reusable components
- **Context encoding**: Conditional logic captures environmental dependencies efficiently
- **Entropy reduction**: Each iteration reduces uncertainty about what makes communication effective

**The evolutionary dynamics:**
- **Variation**: Each template use is a mutation experiment
- **Selection pressure**: User modifications act as fitness feedback
- **Inheritance**: Successful patterns propagate to template offspring
- **Adaptation**: Templates evolve specialized variants for different niches

**The key insight:** Evolution doesn't need to understand the problem to solve it. It only needs variation and selection pressure.

The two-stage reflection system below implements this evolutionary algorithm in practice.

## Two-Stage Reflection System

### Stage 1: Immediate Reflection (After Each Use)

Captures what happened in each template use:

```javascript
/reflect_immediate{
  template: "write_team_email",
  conversation_id: "conv_123",
  modifications: {
    added: ["zoom_link", "mandatory_attendance", "agenda_items"],
    removed: ["generic_closing"],
    restructured: ["moved_deadline_to_subject_line"]
  },
  context: {
    urgency: "high",
    meeting_included: true,
    time_constraint: "same_day"
  },
  outcome: {
    user_satisfaction: "accepted_with_minor_edits",
    response_metrics: {
      team_responses: 11,
      team_size: 12,
      time_to_first_response: 0.5  // hours
    }
  }
}
```

**Data stored for pattern analysis:**
- Feature additions correlate with urgency level
- Quick response time suggests effective structure
- High response rate (91%) indicates clear communication
→ Queue for batch analysis after N uses

### Stage 2: Pattern Analysis (Periodic)

Analyzes patterns across many template uses:

```javascript
/reflect_pattern_analysis{
  template: "write_team_email",
  period: "last_30_days",
  min_instances: 50
}

Analyzing 347 uses of write_team_email template:

High-confidence patterns (statistical significance p < 0.05):
- Meeting links appear in 84% of high-urgency emails (298/347)
- Attendance requirements specified in 91% of meeting emails
- Front-loaded deadlines get 2.5x faster responses
✓ Strong patterns - update template

Conditional patterns discovered:
- IF urgency=high THEN include_meeting_details (84% correlation)
- IF time<9am THEN mention_coffee (89% correlation)
- IF urgency=critical THEN cc_manager (95% correlation)
→ Add conditional branches

Information theory metrics:
- Template entropy before: 4.2 bits (many variations)
- Template entropy after: 2.8 bits (converging on patterns)
- Information gain: 1.4 bits (33% uncertainty reduction)

Common modifications tracked:
1. Add meeting logistics: 84% of urgent emails
2. Specify mandatory/optional: 91% of meetings
3. Include deadline in subject: 76% of time-sensitive
4. Remove pleasantries: 89% of urgent contexts

Anti-patterns identified:
- Long context explanations → 73% get shortened by users
- Missing deadlines → 31% lower response rate
✗ Add constraints to prevent these
```

## Why This Scales Better Than Complex Approaches

### Computational Efficiency

**Traditional approaches:**
- **Multi-agent**: O(n²) communication complexity
- **External memory**: O(n log n) retrieval costs
- **Continual learning**: Risk of catastrophic forgetting

**Templates:**
- **Storage**: O(n) for n templates
- **Execution**: O(1) - same cost as any prompt
- **Learning**: O(m) for m uses of a template
- **No interference** between templates

### Failure Modes

**Complex system failures:**
- Agent deadlock
- Memory corruption
- Catastrophic forgetting

**Template failures:**
- Bad template → predictably bad output
- Easy to debug (human-readable)
- Easy to fix (edit text)
- Easy to revert (version control)

## System Biases and Mitigation

### 1. Recency Bias
**Problem:** Overweighting the last interaction  
**Mitigation:** Pattern analysis requires multiple occurrences before changes

### 2. User Proficiency Bias
**Problem:** Expert users make fewer corrections, novices make many but inconsistent ones  
**Mitigation:** Weight feedback by consistency, not volume

### 3. Context Conflation
**Problem:** Assuming all uses have the same context  
**Mitigation:** Track context explicitly and create variants instead of one-size-fits-all

### 4. Over-Specialization
**Problem:** Template becomes too specific to recent use cases  
**Mitigation:** Maintain "core" vs "variant" template structure

### 5. Confirmation Bias
**Problem:** System only sees successful completions, not when users give up  
**Mitigation:** Track abandonment and explicit negative feedback

### 6. Temporal Drift
**Problem:** Best practices change over time  
**Mitigation:** Decay old learnings, timestamp all patterns

## The Composability Advantage

Templates exhibit **modular evolution** - complex behaviors emerge from simple, composable units:

```
/handle_complex_situation{severity: "high"}
System failure detected. Root cause unknown. Multiple dependencies affected.
Time-critical resolution needed.
```

The template demonstrates **hierarchical composition:**

```
/handle_complex_situation{
  severity: {low|medium|high|critical}
}

\if {severity} == "high" OR {severity} == "critical"
  // Compose specialized sub-templates
  /analyze_dependencies{depth: "full"}
  /generate_hypothesis{method: "fault_tree"}
  /design_experiments{parallel: true}
  /synthesize_findings{confidence_threshold: 0.8}
  
  // Meta-coordination template
  /coordinate_response{
    strategy: "divide_and_conquer",
    parallelize: true,
    checkpoints: "frequent"
  }
\else
  // Simple linear approach for non-critical
  /basic_investigation{systematic: true}
\endif
```

Each sub-template has evolved independently to solve specific sub-problems. Composition allows complex behavior without complex design - **emergent intelligence from simple rules**.

## Required MCP Calls for Implementation

```javascript
// Core template operations
mcp.call('create_template', { name, body, category, tags })
mcp.call('update_template', { name, body, metadata })
mcp.call('get_template', { name })
mcp.call('expand_template', { name, args, context })

// Reflection data storage
mcp.call('store_reflection', { 
  template_name,
  conversation_id,
  usage_context,
  modifications: {
    added: ["zoom_link", "mandatory_spec"],
    removed: ["generic_intro"],
    changed: ["moved_deadline_to_top"]
  },
  outcome: {
    user_accepted: true,
    response_received: true,
    time_to_response: 2.3  // hours
  }
})

// Pattern analysis
mcp.call('analyze_template_usage', {
  template_name,
  period: "30_days",
  min_instances: 20,
  analysis_type: "statistical"  // not "evolutionary"
})

// Learning application
mcp.call('propose_template_update', {
  template_name,
  proposed_changes: {
    add_conditional: {
      condition: "urgency == high",
      content: "Include: [Meeting time] [Zoom link] [Mandatory?]"
    }
  },
  confidence: 0.84,  // based on 84% co-occurrence
  evidence_count: 298
})

// Variant management
mcp.call('create_template_variant', {
  base_template: "write_team_email",
  variant_name: "write_team_email_urgent",
  activation_condition: "urgency >= high",
  modifications: {
    add_prompts: ["meeting_details", "attendance_requirement"]
  }
})

// Performance tracking
mcp.call('get_template_stats', {
  template_name,
  metrics: ['usage_count', 'modification_frequency', 'common_additions'],
  period: "90_days"
})
```

## Conclusion

This system implements a fundamental principle: **complex adaptive systems can evolve solutions without understanding the problem space**. By standardizing interaction patterns (templates) and enabling variation-selection cycles (reflection), we create a self-improving system that discovers optimal communication strategies through use.

**The key insight:** We're not trying to engineer intelligence into the system. We're creating the conditions for intelligence to emerge through evolution.

From an information theory perspective, templates are compression algorithms that evolve to minimize the description length of human intent. From a machine learning perspective, they're implementing online learning with human feedback as the loss function. From an evolutionary perspective, they're digital organisms adapting to the fitness landscape of human communication needs.

**Templates are to LLM improvement what DNA is to biological evolution** - a replicable, mutable, selectable unit of information that enables cumulative adaptation over time. While others try to engineer better organisms, we're discovering the power of evolution itself. 