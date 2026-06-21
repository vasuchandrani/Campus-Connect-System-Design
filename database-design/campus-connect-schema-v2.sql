-- Campus-Connect-Database version-2


-- Users

CREATE TABLE public.users (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  email character varying NOT NULL UNIQUE,
  password character varying NOT NULL,
  gender character varying NOT NULL CHECK (gender::text = ANY (ARRAY['MALE'::character varying, 'FEMALE'::character varying, 'OTHER'::character varying]::text[])),
  profile_pic character varying NOT NULL,
  is_verified boolean NOT NULL,
  college_ann_last_seen_at timestamp without time zone,
  club_ann_last_seen_at timestamp without time zone,
  college_events_last_seen_at timestamp without time zone,
  global_events_last_seen_at timestamp without time zone,
  
  role character varying NOT NULL CHECK (role::text = ANY (ARRAY['COLLEGE_ADMIN'::character varying, 'PROFESSOR'::character varying, 'STUDENT'::character varying]::text[])),
  created_at timestamp without time zone NOT NULL,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

-- College Subscriptions

CREATE TABLE public.college_subscriptions (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  amount numeric NOT NULL,
  admin_email character varying NOT NULL,
  admin_name character varying NOT NULL,
  start_date timestamp without time zone NOT NULL,
  end_date timestamp without time zone NOT NULL,
  order_id character varying NOT NULL,
  payment_id character varying NOT NULL,
  plan_name character varying NOT NULL CHECK (plan_name::text = ANY (ARRAY['BASIC'::character varying, 'PREMIUM'::character varying, 'ENTERPRISE'::character varying]::text[])),
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['ACTIVE'::character varying, 'EXPIRED'::character varying, 'PENDING'::character varying, 'FAILED'::character varying, 'CANCELLED'::character varying]::text[])),
  updated_at timestamp without time zone,
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT college_subscriptions_pkey PRIMARY KEY (id)
);

-- Subscription Histories

CREATE TABLE public.subscription_histories (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  subscription_id bigint NOT NULL,
  plan_name character varying NOT NULL CHECK (plan_name::text = ANY (ARRAY['BASIC'::character varying, 'PREMIUM'::character varying, 'ENTERPRISE'::character varying]::text[])),
  start_date timestamp without time zone NOT NULL,
  end_date timestamp without time zone NOT NULL,
  invoice_url character varying NOT NULL,
  order_id character varying NOT NULL,
  payment_id character varying NOT NULL,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['EXPIRED'::character varying, 'FAILED'::character varying, 'CANCELLED'::character varying]::text[])),

  CONSTRAINT subscription_histories_pkey PRIMARY KEY (id),
  CONSTRAINT fkpepe86a3pw4kav0neoqlsauy9 FOREIGN KEY (subscription_id) REFERENCES public.college_subscriptions(id)
);


-- College Registration Requests

CREATE TABLE public.college_registration_requests (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  subscription_id bigint UNIQUE,
  is_paid boolean NOT NULL,
  name character varying NOT NULL,
  college_email character varying NOT NULL,
  college_phone character varying NOT NULL,
  admin_email character varying NOT NULL,
  admin_name character varying NOT NULL,
  admin_phone character varying NOT NULL,
  about text,
  address text NOT NULL,
  domain character varying,
  logo_url character varying,
  website character varying,
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT college_registration_requests_pkey PRIMARY KEY (id),
  CONSTRAINT fk5ba971e3y12wy24ty7shd0sox FOREIGN KEY (subscription_id) REFERENCES public.college_subscriptions(id)
);

-- Colleges

CREATE TABLE public.colleges (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  subscription_id bigint NOT NULL UNIQUE,
  name character varying NOT NULL,
  college_email character varying NOT NULL,
  college_phone character varying NOT NULL,
  about text,
  address text NOT NULL,
  domain character varying NOT NULL UNIQUE,
  logo_url text,
  website character varying,
  is_active boolean NOT NULL,
  news_publish_control smallint NOT NULL CHECK (news_publish_control >= 0 AND news_publish_control <= 2),
  event_publish_control smallint NOT NULL CHECK (event_publish_control >= 0 AND event_publish_control <= 1),
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT colleges_pkey PRIMARY KEY (id),
  CONSTRAINT fkjwh038ercqqt2swanqr0y43pf FOREIGN KEY (subscription_id) REFERENCES public.college_subscriptions(id)
);

-- College Admins

CREATE TABLE public.college_admins (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  user_id bigint NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  phone_number character varying NOT NULL UNIQUE,

  CONSTRAINT college_admins_pkey PRIMARY KEY (id),
  CONSTRAINT fkkteslnogddct7rdwhfd9bgv1g FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fkalj38wy9b1we8u6170kj93ck8 FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Professors

CREATE TABLE public.professors (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  user_id bigint NOT NULL UNIQUE,
  about text,
  full_name character varying NOT NULL,
  portfolio_link text,

  CONSTRAINT professors_pkey PRIMARY KEY (id),
  CONSTRAINT fkogc82f9uoeow94owmmaeqo0qm FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fklq1bc4wecor3b2lr0whjiimy8 FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Students

CREATE TABLE public.students (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  user_id bigint NOT NULL UNIQUE,
  student_id character varying NOT NULL,
  full_name character varying NOT NULL,
  batch_year integer NOT NULL,
  department character varying NOT NULL,

  CONSTRAINT students_pkey PRIMARY KEY (id),
  CONSTRAINT fk5m8jbc0pre8wg5u8wfgylnfv7 FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fkdt1cjx5ve5bdabmuuf3ibrwaq FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Journalists Requests

CREATE TABLE public.journalist_requests (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  student_id bigint NOT NULL UNIQUE,
  experience text NOT NULL,
  why text NOT NULL,
  portfolio_link text NOT NULL,
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT journalist_requests_pkey PRIMARY KEY (id),
  CONSTRAINT fklgdvya76jjlq4gwhb4nb73qk7 FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fk67tsri0eg46ai4635k6dnlpdx FOREIGN KEY (student_id) REFERENCES public.students(id)
);

-- Journalists

CREATE TABLE public.journalists (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  student_id bigint NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  password_hash character varying NOT NULL,
  is_active boolean NOT NULL,
  about character varying,
  portfolio character varying,
  accepted_by bigint NOT NULL,
  joined_at timestamp without time zone NOT NULL,

  CONSTRAINT journalists_pkey PRIMARY KEY (id),
  CONSTRAINT fk420teusbp3dtx20ecppa0lixu FOREIGN KEY (accepted_by) REFERENCES public.users(id),
  CONSTRAINT fkm23s0p9c1unfhvvvdsudlmsj8 FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fkbn4vo2f9slrgns5w2e3soycxl FOREIGN KEY (student_id) REFERENCES public.students(id)
);

-- Departments

CREATE TABLE public.departments (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  department_name character varying NOT NULL,

  CONSTRAINT departments_pkey PRIMARY KEY (id),
  CONSTRAINT fksmh4d91rvr9whcb3j8e40xrr5 FOREIGN KEY (college_id) REFERENCES public.colleges(id)
);

-- Locations

CREATE TABLE public.locations (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  address text NOT NULL,
  city character varying NOT NULL,
  country character varying NOT NULL,
  state character varying NOT NULL,

  CONSTRAINT locations_pkey PRIMARY KEY (id)
);

-- Club Requests

CREATE TABLE public.club_requests (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  student_id bigint NOT NULL,
  club_name character varying NOT NULL,
  club_description text NOT NULL,
  proposal text NOT NULL,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['PENDING'::character varying, 'ACCEPTED'::character varying, 'REJECTED'::character varying]::text[])),
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT club_requests_pkey PRIMARY KEY (id),
  CONSTRAINT fk69owvhb0tua99nsmo441yg3pm FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fken4qqlywl8onur4qtxagfoh09 FOREIGN KEY (student_id) REFERENCES public.students(id)
);

-- Clubs

CREATE TABLE public.clubs (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  mentor_id bigint,
  club_name character varying NOT NULL,
  tagline_1 character varying,
  tagline_2 character varying,
  description text,
  logo_url text,
  website character varying,
  is_active boolean NOT NULL,
  announcement_publish_control smallint NOT NULL CHECK (announcement_publish_control >= 0 AND announcement_publish_control <= 2),
  event_publish_control smallint NOT NULL CHECK (event_publish_control >= 0 AND event_publish_control <= 2),
  founded_by character varying NOT NULL,
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT clubs_pkey PRIMARY KEY (id),
  CONSTRAINT fknbky87kgk4ayi8e8vpjht6m6j FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fksx9adan05arbbs1lccbqvfaoh FOREIGN KEY (mentor_id) REFERENCES public.professors(id)
);

-- Club Followers

CREATE TABLE public.club_followers (
  club_id bigint NOT NULL,
  student_id bigint NOT NULL,

  CONSTRAINT club_followers_pkey PRIMARY KEY (club_id, student_id),
  CONSTRAINT fkf38mg83pwqnju2da74ghfub39 FOREIGN KEY (club_id) REFERENCES public.clubs(id),
  CONSTRAINT fknfkq3cn542nc6qecrwi2vbdu1 FOREIGN KEY (student_id) REFERENCES public.students(id)
);

-- Club Members

CREATE TABLE public.club_members (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  club_id bigint NOT NULL,
  user_id bigint NOT NULL,
  role character varying NOT NULL CHECK (role::text = ANY (ARRAY['ADMIN'::character varying, 'MEMBER'::character varying]::text[])),
  joined_at timestamp without time zone NOT NULL,

  CONSTRAINT club_members_pkey PRIMARY KEY (id),
  CONSTRAINT fkbwqgge4dgaaxukg2hytd9enhp FOREIGN KEY (club_id) REFERENCES public.clubs(id),
  CONSTRAINT fkrhejy2k7mkjakkwdckyps1jfo FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Club Teams

CREATE TABLE public.club_teams (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  club_id bigint NOT NULL,
  team_name character varying NOT NULL,
  team_description character varying,
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT club_teams_pkey PRIMARY KEY (id),
  CONSTRAINT fkm3suk25a4guy6ut0xthjc6qcp FOREIGN KEY (club_id) REFERENCES public.clubs(id)
);

-- Club Team Members

CREATE TABLE public.club_team_members (
  team_id bigint NOT NULL,
  member_id bigint NOT NULL,
  role character varying NOT NULL CHECK (role::text = ANY (ARRAY['LEAD'::character varying, 'MEMBER'::character varying]::text[])),
  joined_at timestamp without time zone NOT NULL,

  CONSTRAINT club_team_members_pkey PRIMARY KEY (member_id, team_id),
  CONSTRAINT fk8ocl7a8ejxwgpjdqdaqfuctbe FOREIGN KEY (member_id) REFERENCES public.club_members(id),
  CONSTRAINT fk6sj9wx5ry6ldk1uvncup968pu FOREIGN KEY (team_id) REFERENCES public.club_teams(id)
);

-- Announcements

CREATE TABLE public.announcements (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  club_id bigint,
  created_by bigint NOT NULL,
  deleted_by bigint,
  department character varying,
  content text,
  image_url text,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['CREATED'::character varying, 'UPDATED'::character varying, 'DELETED'::character varying, 'APPROVED_BY_CLUB_ADMIN'::character varying, 'PUBLISHED'::character varying]::text[])),
  title character varying NOT NULL,
  type character varying NOT NULL CHECK (type::text = ANY (ARRAY['CLUB'::character varying, 'COLLEGE'::character varying]::text[])),
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT announcements_pkey PRIMARY KEY (id),
  CONSTRAINT fki9awnhlsny8bajneyw04mpqw1 FOREIGN KEY (club_id) REFERENCES public.clubs(id),
  CONSTRAINT fkiyeohgcdwn9uebnto9lphxxjm FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fkht7cvemps7a8tjylacwtyyckj FOREIGN KEY (created_by) REFERENCES public.users(id),
  CONSTRAINT fkg9osa7tx30caarv6foji83r05 FOREIGN KEY (deleted_by) REFERENCES public.users(id)
);

-- Events

CREATE TABLE public.events (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  club_id bigint,
  location_id bigint UNIQUE,
  hosted_by character varying NOT NULL CHECK (hosted_by::text = ANY (ARRAY['COLLEGE'::character varying, 'CLUB'::character varying]::text[])),
  event_type character varying NOT NULL CHECK (event_type::text = ANY (ARRAY['OFFLINE'::character varying, 'ONLINE'::character varying]::text[])),
  
  title character varying NOT NULL,
  description text NOT NULL,
  cover_image character varying,
  is_public boolean NOT NULL,
  registration_payment character varying NOT NULL CHECK (registration_payment::text = ANY (ARRAY['PAID'::character varying, 'PAID_FOR_GUEST'::character varying, 'FREE'::character varying]::text[])),
  selected_registration_fields jsonb,
  custom_registration_fields jsonb,

  registration_start timestamp without time zone NOT NULL,
  registration_end timestamp without time zone NOT NULL,
  start_time timestamp without time zone NOT NULL,
  end_time timestamp without time zone NOT NULL,
  
  department character varying,
  criteria text,
  eligibility text,
  prize_money integer,
  
  overview text,
  participation integer,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['CREATED'::character varying, 'UPDATED'::character varying, 'DELETED'::character varying, 'APPROVED_BY_CLUB_ADMIN'::character varying, 'PUBLISHED'::character varying, 'LIVE'::character varying, 'COMPLETED'::character varying]::text[])),
  created_by bigint NOT NULL,
  deleted_by bigint,
  created_at timestamp without time zone NOT NULL,
  
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT fkmt9rjn9hbh6g8isda7c1g14bd FOREIGN KEY (club_id) REFERENCES public.clubs(id),
  CONSTRAINT fk3g7eqy9h9kov3icbumnqmjsj3 FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fkmpv90a1lsx9lcxsj7xjcvvsxg FOREIGN KEY (created_by) REFERENCES public.users(id),
  CONSTRAINT fk58faqyvpfpxm8cskaqysr062n FOREIGN KEY (deleted_by) REFERENCES public.users(id),
  CONSTRAINT fk7a9tiyl3gaugxrtjc2m97awui FOREIGN KEY (location_id) REFERENCES public.locations(id)
);

-- Event Images

CREATE TABLE public.event_images (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  event_id bigint NOT NULL,
  image_url character varying NOT NULL,

  CONSTRAINT event_images_pkey PRIMARY KEY (id),
  CONSTRAINT fk90aphyy4imr1x6rvklnvtmat6 FOREIGN KEY (event_id) REFERENCES public.events(id)
);

-- Event Registration Plans

CREATE TABLE public.event_registration_plans (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  event_id bigint NOT NULL,
  name character varying NOT NULL,
  description character varying,
  price numeric NOT NULL,
  max_seats integer,

  CONSTRAINT event_registration_plans_pkey PRIMARY KEY (id),
  CONSTRAINT fk443fd6f0bwoe1qheh0ahb8q73 FOREIGN KEY (event_id) REFERENCES public.events(id)
);

-- Event Registrations

CREATE TABLE public.event_registrations (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  event_id bigint NOT NULL,
  student_id bigint NOT NULL,
  registration_plan_id bigint,
  registration_data jsonb,
  registered_at timestamp without time zone NOT NULL,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['REGISTERED'::character varying, 'CANCELLED'::character varying, 'PAYMENT_PENDING'::character varying, 'PAYMENT_COMPLETED'::character varying]::text[])),

  CONSTRAINT event_registrations_pkey PRIMARY KEY (id),
  CONSTRAINT fk6eykq6wu4n23qhn5vwb8kyut5 FOREIGN KEY (event_id) REFERENCES public.events(id),
  CONSTRAINT fk3vou6xqidyvoghjwgckehpc6q FOREIGN KEY (registration_plan_id) REFERENCES public.event_registration_plans(id),
  CONSTRAINT fkfy0x6kh7hht5lagkos3iqnesm FOREIGN KEY (student_id) REFERENCES public.students(id)
);

-- Event Speakers

CREATE TABLE public.event_speakers (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  event_id bigint NOT NULL,
  speaker_name character varying NOT NULL,
  email character varying,
  description text,

  CONSTRAINT event_speakers_pkey PRIMARY KEY (id),
  CONSTRAINT fkflceys4a3r2u575pf1mkmuobw FOREIGN KEY (event_id) REFERENCES public.events(id)
);

-- Event Sponsors

CREATE TABLE public.event_sponsors (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  event_id bigint NOT NULL,
  sponsor_name character varying NOT NULL,
  email character varying,
  description text,

  CONSTRAINT event_sponsors_pkey PRIMARY KEY (id),
  CONSTRAINT fk5olsee36eb239q1xavgjibrhs FOREIGN KEY (event_id) REFERENCES public.events(id)
);

-- Event Winners

CREATE TABLE public.event_winners (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  event_id bigint NOT NULL,
  winner_name character varying NOT NULL,
  registration_id bigint,
  prize text,
 
  CONSTRAINT event_winners_pkey PRIMARY KEY (id),
  CONSTRAINT fko0hsj6yy2s3mwgp2psnlf306p FOREIGN KEY (event_id) REFERENCES public.events(id),
  CONSTRAINT fk62edxs479fpolilcix4giwn60 FOREIGN KEY (registration_id) REFERENCES public.event_registrations(id)
);

-- News Papers

CREATE TABLE public.news_papers (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  journalist_id bigint NOT NULL,
  title character varying NOT NULL,
  content text NOT NULL,
  cover_image text NOT NULL,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['DRAFT'::character varying, 'CREATED'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying, 'DELETED'::character varying, 'GLOBALIZATION_REQUESTED'::character varying, 'UNDER_VOTING'::character varying, 'GLOBALLY_PUBLISHED'::character varying]::text[])),
  
  created_at timestamp without time zone NOT NULL,
  accepted_by bigint,
  deleted_by bigint,

  CONSTRAINT news_papers_pkey PRIMARY KEY (id),
  CONSTRAINT fkmqjw27p3971exw1jrdvgq1hpi FOREIGN KEY (accepted_by) REFERENCES public.users(id),
  CONSTRAINT fklgc7ll1lrnsjgjerj2lj8rvi FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fk9swsyvxlx6ikm2uxysgsb7h6i FOREIGN KEY (deleted_by) REFERENCES public.college_admins(id),
  CONSTRAINT fkelpelns0qwgvgayl7bc39jt20 FOREIGN KEY (journalist_id) REFERENCES public.journalists(id)
);

-- News Globalization Votes

CREATE TABLE public.news_globalization_votes (
  news_id bigint NOT NULL,
  admin_id bigint NOT NULL,
  vote_type character varying NOT NULL CHECK (vote_type::text = ANY (ARRAY['AGREE'::character varying, 'DISAGREE'::character varying]::text[])),

  CONSTRAINT news_globalization_votes_pkey PRIMARY KEY (admin_id, news_id),
  CONSTRAINT fk4kx2mrvq9sw509ho6myrujoql FOREIGN KEY (admin_id) REFERENCES public.college_admins(id),
  CONSTRAINT fkid7dgx9lgqipxv3u0p4osg8m6 FOREIGN KEY (news_id) REFERENCES public.news_papers(id)
);

-- News Upvotes

CREATE TABLE public.news_upvotes (
  news_id bigint NOT NULL,
  user_id bigint NOT NULL,

  CONSTRAINT news_upvotes_pkey PRIMARY KEY (news_id, user_id),
  CONSTRAINT fksq432dcftiis1p3fff3g64sjy FOREIGN KEY (news_id) REFERENCES public.news_papers(id),
  CONSTRAINT fkhcf4jrgysx3vsogunbgsjm0u6 FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Research Papers

CREATE TABLE public.research_papers (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  professor_id bigint,
  student_id bigint NOT NULL,
  ai_score integer,
  prof_feedback text,
  title character varying NOT NULL,
  subject character varying NOT NULL,
  overview text NOT NULL,
  pdf_url text NOT NULL,
  department character varying NOT NULL,
  created_at timestamp without time zone NOT NULL,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['PROFESSOR_SUBMITTED'::character varying, 'STUDENT_SUBMITTED'::character varying, 'UNDER_REVIEW'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying, 'DELETED'::character varying, 'GLOBALIZATION_REQUESTED'::character varying, 'UNDER_VOTING'::character varying, 'GLOBALLY_PUBLISHED'::character varying]::text[])),
  deleted_by bigint,

  CONSTRAINT research_papers_pkey PRIMARY KEY (id),
  CONSTRAINT fk6yissys8tuarw25fcq7g6j2in FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fkqqp92omf0eqq04rbuv4gjcysa FOREIGN KEY (deleted_by) REFERENCES public.college_admins(id),
  CONSTRAINT fki2jbw9jqompn3o5kwlio8lll FOREIGN KEY (professor_id) REFERENCES public.professors(id),
  CONSTRAINT fk7fdf00altn32qk1o8l86nq5c2 FOREIGN KEY (student_id) REFERENCES public.students(id)
);

-- Research Globalization Votes

CREATE TABLE public.research_globalization_votes (
  research_id bigint NOT NULL,
  admin_id bigint NOT NULL,
  vote_type character varying NOT NULL CHECK (vote_type::text = ANY (ARRAY['AGREE'::character varying, 'DISAGREE'::character varying]::text[])),

  CONSTRAINT research_globalization_votes_pkey PRIMARY KEY (admin_id, research_id),
  CONSTRAINT fkerw4o4lsinlq91v70qqesi4mb FOREIGN KEY (admin_id) REFERENCES public.college_admins(id),
  CONSTRAINT fkecp3cc94fuytk23m1fxbrhm0k FOREIGN KEY (research_id) REFERENCES public.research_papers(id)
);

-- Research Papers Upvotes

CREATE TABLE public.research_papers_uppvotes (
  research_id bigint NOT NULL,
  user_id bigint NOT NULL,

  CONSTRAINT research_papers_uppvotes_pkey PRIMARY KEY (research_id, user_id),
  CONSTRAINT fkou8gabo6wn0d0xdwri6g67d16 FOREIGN KEY (research_id) REFERENCES public.research_papers(id),
  CONSTRAINT fka2a7x670k67extl6v2hebtifu FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- System Admins

CREATE TABLE public.system_admins (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  email character varying NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  password character varying NOT NULL,

  CONSTRAINT system_admins_pkey PRIMARY KEY (id)
);

-- CC Events

CREATE TABLE public.cc_events (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  location_id bigint UNIQUE,
  hosted_by character varying NOT NULL,
  event_type character varying NOT NULL CHECK (event_type::text = ANY (ARRAY['OFFLINE'::character varying, 'ONLINE'::character varying]::text[])),
  
  title character varying NOT NULL,
  description text NOT NULL,
  cover_image character varying,
  criteria text,
  eligibility text,
  
  selected_registration_fields jsonb,
  custom_registration_fields jsonb,
  registration_payment character varying NOT NULL CHECK (registration_payment::text = ANY (ARRAY['PAID'::character varying, 'FREE'::character varying]::text[])),
  registration_start timestamp without time zone NOT NULL,
  registration_end timestamp without time zone NOT NULL,
  start_time timestamp without time zone NOT NULL,
  end_time timestamp without time zone NOT NULL,
  
  overview text,
  prize_money integer,
  participation integer,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['DRAFT'::character varying, 'PUBLISHED'::character varying, 'DELETED'::character varying, 'LIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying]::text[])),
  created_at timestamp without time zone NOT NULL,
  created_by bigint NOT NULL,
  deleted_by bigint,

  CONSTRAINT cc_events_pkey PRIMARY KEY (id),
  CONSTRAINT fk22ay8vmind6v0vprr7uja37fm FOREIGN KEY (created_by) REFERENCES public.system_admins(id),
  CONSTRAINT fkq04ujpjciy75x11d80aaxmpl3 FOREIGN KEY (deleted_by) REFERENCES public.users(id),
  CONSTRAINT fk1iv8ct5x17a6ymf7blavh8hnq FOREIGN KEY (location_id) REFERENCES public.locations(id)
);

-- CC Events Registration Plans

CREATE TABLE public.cc_event_registration_plans (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  cc_event_id bigint NOT NULL,
  name character varying NOT NULL,
  description character varying,
  price numeric NOT NULL,
  max_seats integer,

  CONSTRAINT cc_event_registration_plans_pkey PRIMARY KEY (id),
  CONSTRAINT fks4fda90jk9kp3d46oqr9qrwi2 FOREIGN KEY (cc_event_id) REFERENCES public.cc_events(id)
);

-- CC Event Registrations

CREATE TABLE public.cc_event_registrations (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  cc_event_id bigint NOT NULL,
  user_id bigint NOT NULL,
  registration_plan_id bigint,
  registration_data jsonb,
  registered_at timestamp without time zone NOT NULL,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['REGISTERED'::character varying, 'CANCELLED'::character varying, 'PAYMENT_PENDING'::character varying, 'PAYMENT_COMPLETED'::character varying]::text[])),

  CONSTRAINT cc_event_registrations_pkey PRIMARY KEY (id),
  CONSTRAINT fkc1w8g15xf3btj0ito74rdi3rc FOREIGN KEY (registration_plan_id) REFERENCES public.cc_event_registration_plans(id),
  CONSTRAINT fku9bb9xb0nx68rubt9ary08sg FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT fkfqpgjobd8xq92yr3c86aa73er FOREIGN KEY (cc_event_id) REFERENCES public.cc_events(id)
);