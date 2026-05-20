-- Add the 1-based source line of the quiz block in the lecture's
-- markdown file. Lets the dashboard build a GitHub deep-link of
-- the form ".../blob/<sha>/lectures/<f>.md?plain=1#L<line>" that
-- jumps the reader straight to the question text. Old rows have
-- NULL line; the dashboard falls back to the no-anchor URL.

ALTER TABLE quiz_response ADD COLUMN line INTEGER;
