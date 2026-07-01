# Why the Redesign?

## Background

The first version of CampusConnect was designed around the assumption that each college would operate independently on the platform.

The initial database and software architecture successfully supported the original requirements and allowed the first version of the product to be developed.

However, as the business vision evolved, several new opportunities emerged that were not considered during the initial design.

## What Changed?

During product development, it became clear that CampusConnect was not simply serving one college.

Instead, it was becoming a platform connecting multiple colleges through a shared ecosystem.

This realization fundamentally changed the business model.

## New Features Identified

Several new features were discovered:

### Cross-College Events

Events should not always be limited to a single college.

A college should be able to publish selected events to students from other colleges participating on the platform.

### Dynamic Event Registration

Although student information is already stored, different events require different information.

Examples include:

- Team Name
- Team Size
- GitHub Repository
- Resume
- Portfolio Link
- Meal Preference

Instead of fixed registration forms, event organizers should be able to define additional registration fields during event creation.

### Paid Events

Events may require payment.

Some events may also support multiple pricing plans, such as:

- One Day Pass
- Two Day Pass
- Full Event Pass

This introduces payment processing and pricing management into the platform.

### External Event Promotions

CampusConnect can also become a promotional platform.

External organizers may publish events such as:

- Stand-up Comedy Shows
- Workshops
- Tech Conferences
- Career Fairs

These organizers can pay to promote events to students across selected colleges.

This opens a new revenue stream for the platform.

### Cross-College Content

The same concept can be extended beyond events.

Research papers and digital newspapers should also be discoverable across colleges when permitted.

This enables knowledge sharing between institutions.

### Better Administrative Control

College administrators should have configurable control over content visibility.

Examples include:

- Who can publish globally?
- Which roles require approval?
- What content remains private to the college?

Administrative permissions need to become more flexible than the first version.

## Why the Existing Architecture Falls Short

The original architecture was built around a single-college ecosystem.

As new requirements continued to emerge, supporting them required introducing additional entities, relationships, and business rules that were never considered during the initial database design.

Rather than continuously patching the existing architecture, a complete redesign provides a cleaner, more scalable, and future-ready foundation.

## Conclusion

The redesign is driven primarily by the evolution of the business model rather than technical limitations alone.

The objective is to redesign the system around the long-term vision of CampusConnect instead of incrementally extending assumptions made during the first implementation.