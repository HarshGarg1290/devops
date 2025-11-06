DELETE FROM POST;
DELETE FROM USERS;

INSERT INTO USERS (username,password) VALUES
('alice','alicepass'),
('bob','bobpass'),
('carol','carolpass'),
('dave','davepass'),
('eve','evepass');

INSERT INTO POST (content, created_at, user_id) VALUES
('Exploring the new InsightFeed — happy to share my first post!', CURRENT_TIMESTAMP, 1),
('A quick tip about productivity: batch similar tasks and focus blocks work wonders.', CURRENT_TIMESTAMP, 2),
('Thoughts on microservices: keep interfaces simple and document them well.', CURRENT_TIMESTAMP, 3),
('Weekend reading list: an intro to observability, and a deep-dive on tracing.', CURRENT_TIMESTAMP, 4),
('Why I switched to Tailwind for small projects: rapid iteration and consistent styles.', CURRENT_TIMESTAMP, 5),
('DevOps note: automated infra tests saved us from a bad deploy — write them early.', CURRENT_TIMESTAMP, 1),
('Short poem: code compiles, tests pass — celebration time!', CURRENT_TIMESTAMP, 2),
('Opinion: dark theme is easier on the eyes for long editing sessions.', CURRENT_TIMESTAMP, 3),
('On debugging: reproduce, isolate, and add logging — repeat.', CURRENT_TIMESTAMP, 4),
('Sharing a long-form post: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet.', CURRENT_TIMESTAMP, 5),
('Tips: back up your H2 DB for local experiments before destructive tests.', CURRENT_TIMESTAMP, 1),
('Announcement: migrating a small project to Kubernetes — notes and pitfalls.', CURRENT_TIMESTAMP, 2),
('Short status update: completed refactor and cleaned up deprecated endpoints.', CURRENT_TIMESTAMP, 3),
('Question: how do you handle secrets in CI for hobby projects?', CURRENT_TIMESTAMP, 4),
('Random thought: naming things well matters more than expected.', CURRENT_TIMESTAMP, 5),
('A longer post about testing: unit tests, integration tests, and end-to-end — each has its place. Make them fast and deterministic.', CURRENT_TIMESTAMP, 1),
('Community: welcome new contributors — create small issues for onboarding.', CURRENT_TIMESTAMP, 2),
('Tooling: I like Docker multi-stage builds to keep images small.', CURRENT_TIMESTAMP, 3),
('Performance: measure before optimizing — add a benchmark.', CURRENT_TIMESTAMP, 4),
('Design: prefer composition over inheritance for small services.', CURRENT_TIMESTAMP, 5),
('Field note: Debugging network issues on AWS — check SGs and NACLs first.', CURRENT_TIMESTAMP, 1),
('Reflection: incremental improvements beat big rewrites most of the time.', CURRENT_TIMESTAMP, 2),
('How I write posts: outline, rough draft, refine, then publish.', CURRENT_TIMESTAMP, 3),
('Final thought: keep your README helpful — it pays off.', CURRENT_TIMESTAMP, 4),
('Signing off: thanks for reading — follow for more InsightFeed updates!', CURRENT_TIMESTAMP, 5);
