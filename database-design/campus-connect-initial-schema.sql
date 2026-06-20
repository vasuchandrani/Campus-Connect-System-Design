-- Campus-Connect-Database version-1

-- College

CREATE TABLE public.college (
  is_active boolean,
  is_verified boolean NOT NULL,
  created_at timestamp without time zone,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  about character varying,
  address character varying,
  domain character varying NOT NULL UNIQUE,
  logo character varying,
  name character varying NOT NULL UNIQUE,
  website character varying,

  CONSTRAINT college_pkey PRIMARY KEY (id)
);

-- College Admin

CREATE TABLE public.college_admin (
  college_id bigint NOT NULL UNIQUE,
  created_at timestamp without time zone,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  email character varying NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  password_hash character varying NOT NULL,
  phone_number character varying NOT NULL UNIQUE,

  CONSTRAINT college_admin_pkey PRIMARY KEY (id),
  CONSTRAINT fkkfgpu5teqq3i4uye0e5ekygod FOREIGN KEY (college_id) REFERENCES public.college(id)
);

-- College Subscription

CREATE TABLE public.college_subscription (
  amount integer NOT NULL,
  college_id bigint NOT NULL UNIQUE,
  end_date timestamp without time zone NOT NULL,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  start_date timestamp without time zone NOT NULL,
  admin_email character varying NOT NULL,
  admin_name character varying NOT NULL,
  invoice_url character varying,
  order_id character varying NOT NULL,
  payment_id character varying NOT NULL,
  plan_name character varying NOT NULL,
  
  CONSTRAINT college_subscription_pkey PRIMARY KEY (id),
  CONSTRAINT fk4dfkmxxboigwyah12hungetny FOREIGN KEY (college_id) REFERENCES public.college(id)
);

-- Student

CREATE TABLE public.student (
  is_verified boolean NOT NULL,
  year integer NOT NULL,
  college_id bigint,
  created_at timestamp without time zone,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  department character varying NOT NULL,
  email character varying NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  gender character varying,
  password_hash character varying NOT NULL,
  student_id character varying NOT NULL UNIQUE,
  
  CONSTRAINT student_pkey PRIMARY KEY (id),
  CONSTRAINT fklq9gp46xirqgtyslqs0wkowu5 FOREIGN KEY (college_id) REFERENCES public.college(id)
);

-- Journalist Request

CREATE TABLE public.journalist_request (
  college_id bigint,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  student_id bigint UNIQUE,
  experience character varying NOT NULL,
  portfolio_link character varying NOT NULL,
  why character varying NOT NULL,
  
  CONSTRAINT journalist_request_pkey PRIMARY KEY (id),
  CONSTRAINT fkof4xpvrdm79ecbfr705sck8d4 FOREIGN KEY (college_id) REFERENCES public.college(id),
  CONSTRAINT fk100sshmfpuw5dih4b3ru8dimj FOREIGN KEY (student_id) REFERENCES public.student(id)
);

-- Journalist

CREATE TABLE public.journalist (
  is_active boolean,
  college_id bigint,
  created_at timestamp without time zone,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  about character varying,
  email character varying NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  password_hash character varying NOT NULL,
  portfolio character varying,
  
  CONSTRAINT journalist_pkey PRIMARY KEY (id),
  CONSTRAINT fkrlchxp964mmi73kfpc1at9mj6 FOREIGN KEY (college_id) REFERENCES public.college(id),
  CONSTRAINT fkqj0nxyhpykgxy3hwva3u4j207 FOREIGN KEY (email) REFERENCES public.student(email)
);

-- News Paper

CREATE TABLE public.news_paper (
  college_id bigint NOT NULL,
  created_at timestamp without time zone NOT NULL,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  journalist_id bigint NOT NULL,
  content text NOT NULL,
  image_url character varying NOT NULL,
  status character varying NOT NULL,
  title character varying NOT NULL,
  
  CONSTRAINT news_paper_pkey PRIMARY KEY (id),
  CONSTRAINT fk3pyy25iihtchf536bppm5es7 FOREIGN KEY (college_id) REFERENCES public.college(id),
  CONSTRAINT fk74b8ax6p1uo95yg5oxmcrsx49 FOREIGN KEY (journalist_id) REFERENCES public.journalist(id)
);

-- Club Requests

CREATE TABLE public.club_request (
  college_id bigint NOT NULL,
  created_at timestamp without time zone NOT NULL,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  student_id bigint NOT NULL,
  club_name character varying NOT NULL,
  description character varying,
  status character varying NOT NULL,

  CONSTRAINT club_request_pkey PRIMARY KEY (id),
  CONSTRAINT fkiearxysjk0b82l3ojekcw94tm FOREIGN KEY (college_id) REFERENCES public.college(id),
  CONSTRAINT fkyt95755vp2qh21nxdrfbis7x FOREIGN KEY (student_id) REFERENCES public.student(id)
);

-- Club

CREATE TABLE public.club (
  college_id bigint NOT NULL,
  created_at timestamp without time zone,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  description character varying,
  logo_url character varying,
  name character varying NOT NULL,
  website character varying,

  CONSTRAINT club_pkey PRIMARY KEY (id),
  CONSTRAINT fkcdsmcdpfpa1wl14xaj6269tqm FOREIGN KEY (college_id) REFERENCES public.college(id)
);

-- Club Followers

CREATE TABLE public.club_followers (
  club_id bigint NOT NULL,
  student_id bigint NOT NULL,
  CONSTRAINT club_followers_pkey PRIMARY KEY (club_id, student_id),
  CONSTRAINT fkcd3riugedy0su75oh3ry4uk2s FOREIGN KEY (club_id) REFERENCES public.club(id),
  CONSTRAINT fkhlxi5ehbijtyhc15l7j6a8l35 FOREIGN KEY (student_id) REFERENCES public.student(id)
);

-- Club Members

CREATE TABLE public.club_member (
  club_id bigint NOT NULL,
  student_id bigint NOT NULL,
  image character varying,
  role character varying NOT NULL,
  CONSTRAINT club_member_pkey PRIMARY KEY (club_id, student_id),
  CONSTRAINT fkf6tl19ih8acrmheidn4xos2tx FOREIGN KEY (club_id) REFERENCES public.club(id),
  CONSTRAINT fk5puo85vt75pvoe4k1ot4b7a25 FOREIGN KEY (student_id) REFERENCES public.student(id)
);

-- Club Team

CREATE TABLE public.club_team (
  club_id bigint NOT NULL,
  created_at timestamp without time zone,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  description character varying,
  name character varying NOT NULL,

  CONSTRAINT club_team_pkey PRIMARY KEY (id),
  CONSTRAINT fkd47d7y6x58el1l0cm395ml8wt FOREIGN KEY (club_id) REFERENCES public.club(id)
);

-- Club Team Members

CREATE TABLE public.club_team_members (
  joined_at timestamp without time zone,
  student_id bigint NOT NULL,
  team_id bigint NOT NULL,
  image character varying,
  role character varying,

  CONSTRAINT club_team_members_pkey PRIMARY KEY (student_id, team_id),
  CONSTRAINT fkpa6y5nnlfkycsgtd57417as84 FOREIGN KEY (student_id) REFERENCES public.student(id),
  CONSTRAINT fk59bqdljpdsumr9wv06c10n1lr FOREIGN KEY (team_id) REFERENCES public.club_team(id)
);

-- Announcement

CREATE TABLE public.announcement (
  club_id bigint,
  created_at timestamp without time zone,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  content character varying,
  title character varying NOT NULL,

  CONSTRAINT announcement_pkey PRIMARY KEY (id),
  CONSTRAINT fk7s74c9og10ht84qkip6j6pa4d FOREIGN KEY (club_id) REFERENCES public.club(id)
);

-- Event

CREATE TABLE public.event (
  participation integer,
  prize_money integer,
  club_id bigint NOT NULL,
  created_at timestamp without time zone,
  end_date timestamp without time zone NOT NULL,
  event_time timestamp without time zone NOT NULL,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  registration_end timestamp without time zone,
  description text NOT NULL,
  image_url character varying,
  location character varying NOT NULL,
  overview text,
  title character varying NOT NULL,

  CONSTRAINT event_pkey PRIMARY KEY (id),
  CONSTRAINT fkge5xi5nf69096gtcjwjtup8wm FOREIGN KEY (club_id) REFERENCES public.club(id)
);

-- Event images

CREATE TABLE public.event_images (
  event_id bigint NOT NULL,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  image_url character varying NOT NULL,

  CONSTRAINT event_images_pkey PRIMARY KEY (id),
  CONSTRAINT fkbf173wtth5u1u7ttu9jeignci FOREIGN KEY (event_id) REFERENCES public.event(id)
);

-- Event Registrations

CREATE TABLE public.event_registrations (
  event_id bigint NOT NULL,
  student_id bigint NOT NULL,

  CONSTRAINT event_registrations_pkey PRIMARY KEY (event_id, student_id),
  CONSTRAINT fks4kjleulewhu881p4nygwdi0 FOREIGN KEY (event_id) REFERENCES public.event(id),
  CONSTRAINT fk9iqgyojplc8c2kqf50v5lqp09 FOREIGN KEY (student_id) REFERENCES public.student(id)
);

-- Event Speakers

CREATE TABLE public.event_speaker (
  event_id bigint,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  email character varying,
  speaker_name character varying NOT NULL,
  tagline character varying NOT NULL,

  CONSTRAINT event_speaker_pkey PRIMARY KEY (id),
  CONSTRAINT fkjmtxwwiao8a0t7jdd6bp5r6bk FOREIGN KEY (event_id) REFERENCES public.event(id)
);

-- Event Sponsors

CREATE TABLE public.event_sponsors (
  event_id bigint,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  sponsor_name character varying NOT NULL,
  tagline character varying NOT NULL,

  CONSTRAINT event_sponsors_pkey PRIMARY KEY (id),
  CONSTRAINT fkgnhs630309gey9vqhynoj8n8 FOREIGN KEY (event_id) REFERENCES public.event(id)
);

-- Event Winners

CREATE TABLE public.event_winner (
  event_id bigint,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  email character varying NOT NULL,
  name character varying NOT NULL,

  CONSTRAINT event_winner_pkey PRIMARY KEY (id),
  CONSTRAINT fk64d1s509ewiitexb29at7ageg FOREIGN KEY (event_id) REFERENCES public.event(id)
);

-- Reviewer

CREATE TABLE public.reviewer (
  college_id bigint,
  created_at timestamp without time zone,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  email character varying NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  password_hash character varying NOT NULL,
  CONSTRAINT reviewer_pkey PRIMARY KEY (id),
  CONSTRAINT fk1ei288mowaf5mg40ds0gulu0p FOREIGN KEY (college_id) REFERENCES public.college(id)
);

-- Research Paper

CREATE TABLE public.research_paper (
  college_id bigint NOT NULL,
  created_at timestamp without time zone NOT NULL,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  reviewer_id bigint,
  student_id bigint NOT NULL,
  department character varying NOT NULL,
  overview text NOT NULL,
  pdf_url character varying,
  reviewer_feedback character varying,
  status character varying NOT NULL,
  subject character varying NOT NULL,
  title character varying NOT NULL,

  CONSTRAINT research_paper_pkey PRIMARY KEY (id),
  CONSTRAINT fkcss9dpii0y78oc96c3c1crmm7 FOREIGN KEY (college_id) REFERENCES public.college(id),
  CONSTRAINT fkebe4o6bisipmbdqjxfqyv048a FOREIGN KEY (reviewer_id) REFERENCES public.reviewer(id),
  CONSTRAINT fkl67217sywvaej9sf0kt1rcko0 FOREIGN KEY (student_id) REFERENCES public.student(id)
);

-- Verification Code

CREATE TABLE public.verification_code (
  verified boolean NOT NULL,
  created_at timestamp without time zone NOT NULL,
  expire_at timestamp without time zone NOT NULL,
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  code character varying NOT NULL,
  email character varying NOT NULL,

  CONSTRAINT verification_code_pkey PRIMARY KEY (id)
);