-- Campus-Connect-Database version-2


-- Common Domain

-- Users

CREATE TABLE public.users (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  email character varying NOT NULL UNIQUE,
  password character varying NOT NULL,
  gender character varying NOT NULL CHECK (gender::text = ANY (ARRAY['MALE'::character varying, 'FEMALE'::character varying, 'OTHER'::character varying]::text[])),
  profile_pic character varying NOT NULL,
  is_verified boolean NOT NULL,
  
  role character varying NOT NULL CHECK (role::text = ANY (ARRAY['COLLEGE_ADMIN'::character varying, 'PROFESSOR'::character varying, 'STUDENT'::character varying]::text[])),
  created_at timestamp without time zone NOT NULL,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

-- Subscription Plans

CREATE TABLE public.subscription_plans (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  plan_name character varying NOT NULL UNIQUE,
  amount numeric NOT NULL,
  features jsonb,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT subscription_plans_pkey PRIMARY KEY (id)
);

-- Locations

CREATE TABLE public.locations (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  address text NOT NULL,
  city character varying NOT NULL,
  state character varying NOT NULL,
  country character varying NOT NULL,

  CONSTRAINT locations_pkey PRIMARY KEY (id)
);



-- College Domain

-- College Registration Requests

CREATE TABLE public.college_registration_requests (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  location_id bigint NOT NULL,
  
  college_name character varying NOT NULL,
  college_email character varying NOT NULL,
  college_phone character varying NOT NULL,

  admin_name character varying NOT NULL,
  admin_email character varying NOT NULL,
  admin_phone character varying NOT NULL,
  
  about text,
  domain character varying,
  logo_url character varying,
  website character varying,
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT college_registration_requests_pkey PRIMARY KEY (id),
  CONSTRAINT fk_college_registration_requests_location FOREIGN KEY (location_id) REFERENCES public.locations(id)
);

-- College Subscriptions

CREATE TABLE public.college_subscriptions (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  plan_id bigint NOT NULL,
  admin_email character varying NOT NULL,
  admin_name character varying NOT NULL,

  start_date timestamp without time zone NOT NULL,
  end_date timestamp without time zone NOT NULL,
  
  order_id character varying NOT NULL,
  payment_id character varying NOT NULL,
  invoice_url character varying NOT NULL,

  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['ACTIVE'::character varying, 'EXPIRED'::character varying, 'PENDING'::character varying, 'FAILED'::character varying, 'CANCELLED'::character varying]::text[])),
  updated_at timestamp without time zone,
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT college_subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT fk_college_subscriptions_plan_id FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id)
);

-- Subscription Histories

CREATE TABLE public.college_subscription_histories (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,

  college_id bigint NOT NULL,
  plan_id bigint NOT NULL,

  start_date timestamp without time zone NOT NULL,
  end_date timestamp without time zone NOT NULL,
  
  invoice_url character varying NOT NULL,
  order_id character varying NOT NULL,
  payment_id character varying NOT NULL,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['EXPIRED'::character varying, 'FAILED'::character varying, 'CANCELLED'::character varying]::text[])),

  CONSTRAINT college_subscription_histories_pkey PRIMARY KEY (id),
  CONSTRAINT fkpepe86a3pw4kav0neoqlsauy9 FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fk_college_subscription_histories_plan_id FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id)
);

-- Colleges

CREATE TABLE public.colleges (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  subscription_id bigint UNIQUE,
  location_id bigint NOT NULL,
  
  college_name character varying NOT NULL,
  college_email character varying NOT NULL,
  college_phone character varying NOT NULL,
  
  about text,
  domain character varying NOT NULL UNIQUE,
  logo_url text,
  website character varying,
  is_active boolean NOT NULL,
  
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,

  CONSTRAINT colleges_pkey PRIMARY KEY (id),
  CONSTRAINT fkjwh038ercqqt2swanqr0y43pf FOREIGN KEY (subscription_id) REFERENCES public.college_subscriptions(id),
  CONSTRAINT fk_colleges_location FOREIGN KEY (location_id) REFERENCES public.locations(id)
);

-- College Settings

CREATE TABLE public.college_settings (
  college_id bigint NOT NULL,

  -- Club publishing control
  club_publishing_settings character varying NOT NULL DEFAULT 'APPROVAL_NEEDED' CHECK (club_publishing_settings::text = ANY (ARRAY['APPROVAL_NEEDED'::character varying, 'NO_APPROVAL_NEEDED'::character varying]::text[])), 

  -- College-Announcements publishing controls
  college_announcement_publishing_settings character varying NOT NULL DEFAULT 'APPROVAL_NEEDED' CHECK (college_announcement_publishing_settings::text = ANY (ARRAY['APPROVAL_NEEDED'::character varying, 'NO_APPROVAL_NEEDED'::character varying]::text[])), 

  -- College-Event publishing controls
  college_event_publishing_settings character varying NOT NULL DEFAULT 'APPROVAL_NEEDED' CHECK (college_event_publishing_settings::text = ANY (ARRAY['APPROVAL_NEEDED'::character varying, 'NO_APPROVAL_NEEDED'::character varying]::text[])), 

  -- Newspaper publishing control
  newspaper_publishing_settings character varying NOT NULL DEFAULT 'MENTOR_APPROVAL_NEEDED' CHECK (newspaper_publishing_settings::text = ANY (ARRAY['MENTOR_APPROVAL_NEEDED'::character varying, 'JOURNALIST_CAN_PUBLISH'::character varying]::text[])), 

  -- Minimum Journalist Re-Request time 
  journalist_re_request_minimum_time int NOT NULL,

  -- Minimum Club Re-Request time 
  club_re_request_minimum_time int NOT NULL,

  CONSTRAINT college_settings_pkey PRIMARY KEY (college_id),
  CONSTRAINT fk_college_settings_college FOREIGN KEY (college_id) REFERENCES public.colleges(id) ON DELETE CASCADE
);

-- Departments

CREATE TABLE public.departments (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  department_name character varying NOT NULL,

  CONSTRAINT departments_pkey PRIMARY KEY (id),
  CONSTRAINT fksmh4d91rvr9whcb3j8e40xrr5 FOREIGN KEY (college_id) REFERENCES public.colleges(id)
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
  full_name character varying NOT NULL,
  about text,

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
  
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['PENDING'::character varying, 'REJECTED'::character varying]::text[])),
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
  portfolio_link character varying,
  accepted_by bigint NOT NULL,
  joined_at timestamp without time zone NOT NULL,

  CONSTRAINT journalists_pkey PRIMARY KEY (id),
  CONSTRAINT fk420teusbp3dtx20ecppa0lixu FOREIGN KEY (accepted_by) REFERENCES public.users(id),
  CONSTRAINT fkm23s0p9c1unfhvvvdsudlmsj8 FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fkbn4vo2f9slrgns5w2e3soycxl FOREIGN KEY (student_id) REFERENCES public.students(id)
);


-- Club Domain

-- Club Requests

CREATE TABLE public.club_requests (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  student_id bigint NOT NULL,
  
  club_name character varying NOT NULL,
  club_description text NOT NULL,
  proposal text NOT NULL,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['PENDING'::character varying, 'REJECTED'::character varying]::text[])),
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT club_requests_pkey PRIMARY KEY (id),
  CONSTRAINT fk69owvhb0tua99nsmo441yg3pm FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fken4qqlywl8onur4qtxagfoh09 FOREIGN KEY (student_id) REFERENCES public.students(id)
);

-- Clubs

CREATE TABLE public.clubs (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  mentor_id bigint NOT NULL,
  admin_id bigint NOT NULL,

  club_name character varying NOT NULL,
  tagline_1 character varying,
  tagline_2 character varying,
  description text,
  logo_url text,
  website character varying,
  is_active boolean NOT NULL,

  founded_by character varying NOT NULL,
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT clubs_pkey PRIMARY KEY (id),
  CONSTRAINT college_fkey FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT mentor_fkey FOREIGN KEY (mentor_id) REFERENCES public.professors(id),
  CONSTRAINT admin_fkey FOREIGN KEY (admin_id) REFERENCES public.students(id)
);

-- Club Settings

CREATE TABLE public.club_settings (

  club_id bigint NOT NULL,

  -- Announcement publishing control
  announcement_publish_settings character varying NOT NULL DEFAULT 'MENTOR_APPROVAL' CHECK (announcement_publish_settings::text = ANY (ARRAY['MENTOR_APPROVAL'::character varying, 'CLUB_ADMIN_APPROVAL'::character varying]::text[])), 

  -- Event publishing control
  event_publish_settings character varying NOT NULL DEFAULT 'MENTOR_APPROVAL' CHECK (event_publish_settings::text = ANY (ARRAY['MENTOR_APPROVAL'::character varying, 'CLUB_ADMIN_APPROVAL'::character varying]::text[])),

  CONSTRAINT club_settings_pkey PRIMARY KEY (club_id),
  CONSTRAINT fk_club_settings_club FOREIGN KEY (club_id) REFERENCES public.clubs(id) ON DELETE CASCADE
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
  student_id bigint NOT NULL,

  joined_at timestamp without time zone NOT NULL,

  CONSTRAINT club_members_pkey PRIMARY KEY (id),
  CONSTRAINT club_fkey FOREIGN KEY (club_id) REFERENCES public.clubs(id),
  CONSTRAINT student_fkey FOREIGN KEY (student_id) REFERENCES public.students(id)
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
  CONSTRAINT member_fkey FOREIGN KEY (member_id) REFERENCES public.club_members(id),
  CONSTRAINT team_fkey FOREIGN KEY (team_id) REFERENCES public.club_teams(id)
);



-- Announcements Domain

-- College Announcements

CREATE TABLE public.college_announcements (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  
  created_by bigint NOT NULL,
  deleted_by bigint,
  
  department_id bigint,
  batch_year integer,

  state int NOT NULL DEFAULT 0, 
  -- 0 - created by professor
  -- 1 - created or approved by college-admin, means published
  
  title character varying NOT NULL,
  content text,
  image_url text,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['CREATED'::character varying, 'UPDATED'::character varying, 'DELETED'::character varying, 'PUBLISHED'::character varying]::text[])),
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT college_announcements_pkey PRIMARY KEY (id),
  CONSTRAINT fk_college_announcements_college FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fk_college_announcements_created_by FOREIGN KEY (created_by) REFERENCES public.users(id),
  CONSTRAINT fk_college_announcements_deleted_by FOREIGN KEY (deleted_by) REFERENCES public.users(id),
  CONSTRAINT fk_college_announcements_department FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL
);

-- Club Announcements

CREATE TABLE public.club_announcements (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  club_id bigint NOT NULL,
  
  created_by bigint NOT NULL,
  deleted_by bigint,

  state int NOT NULL DEFAULT 0, 
  -- 0 - created by club-member
  -- 1 - created or approved by club-admin
  -- 2 - approved by mentor
  -- 3 - approved by college-admin, means published

  title character varying NOT NULL,
  content text,
  image_url text,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['CREATED'::character varying, 'UPDATED'::character varying, 'DELETED'::character varying, 'APPROVED_BY_CLUB_ADMIN'::character varying, 'PUBLISHED'::character varying]::text[])),
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT club_announcements_pkey PRIMARY KEY (id),
  CONSTRAINT fk_club_announcements_club FOREIGN KEY (club_id) REFERENCES public.clubs(id),
  CONSTRAINT fk_club_announcements_college FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fk_club_announcements_created_by FOREIGN KEY (created_by) REFERENCES public.users(id),
  CONSTRAINT fk_club_announcements_deleted_by FOREIGN KEY (deleted_by) REFERENCES public.users(id)
);



-- College Event Domain

-- Events

CREATE TABLE public.events (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  club_id bigint,
  location_id bigint NOT NULL,

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
  
  department_id bigint,
  batch_year integer,
  criteria text,
  eligibility text,
  prize_money integer,
  
  overview text,
  participation integer,
  state int NOT NULL DEFAULT 0,
  -- 0 - created by club-member
  -- 1 - created or approved by club-admin
  -- 2 - approved by mentor
  -- 3 - approved by college-admin, means published within college
  -- 4 - request for globalize
  -- 5 - approved and globalize by college-admin

  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['UPCOMING'::character varying, 'LIVE'::character varying]::text[])),
  created_by bigint NOT NULL,
  deleted_by bigint,
  created_at timestamp without time zone NOT NULL,
  
  CONSTRAINT events_pkey PRIMARY KEY (id),
  CONSTRAINT fkmt9rjn9hbh6g8isda7c1g14bd FOREIGN KEY (club_id) REFERENCES public.clubs(id),
  CONSTRAINT fk3g7eqy9h9kov3icbumnqmjsj3 FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fkmpv90a1lsx9lcxsj7xjcvvsxg FOREIGN KEY (created_by) REFERENCES public.users(id),
  CONSTRAINT fk58faqyvpfpxm8cskaqysr062n FOREIGN KEY (deleted_by) REFERENCES public.users(id),
  CONSTRAINT fk7a9tiyl3gaugxrtjc2m97awui FOREIGN KEY (location_id) REFERENCES public.locations(id),
  CONSTRAINT fk_events_department FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL
);

-- Event Registration Plans

CREATE TABLE public.event_registration_plans (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  event_id bigint NOT NULL,
  plan_name character varying NOT NULL,
  plan_description character varying,
  amount numeric NOT NULL,
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

-- Event Announcements

CREATE TABLE public.event_announcements (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  event_id bigint NOT NULL,
  created_by bigint NOT NULL,

  title character varying NOT NULL,
  content text,
  image_url text,

  created_at timestamp without time zone NOT NULL,

  CONSTRAINT event_announcements_pkey PRIMARY KEY (id),
  CONSTRAINT fk_event_announcements_event FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE,
  CONSTRAINT fk_event_announcements_created_by FOREIGN KEY (created_by) REFERENCES public.users(id),
  CONSTRAINT fk_event_announcements_deleted_by FOREIGN KEY (deleted_by) REFERENCES public.users(id)
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

-- Finished Events

CREATE TABLE public.finished_events (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  title character varying NOT NULL,
  location_id bigint,

  event_type character varying NOT NULL CHECK (event_type::text = ANY (ARRAY['OFFLINE'::character varying, 'ONLINE'::character varying]::text[])),
  
  start_time timestamp without time zone NOT NULL,
  end_time timestamp without time zone NOT NULL,
  
  cover_image character varying,
  overview text,
  
  event_details text NOT NULL, -- Markdown formatted string containing announcements, sponsors, speakers, etc.
  department_id bigint,
  batch_year integer,
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT finished_events_pkey PRIMARY KEY (id),
  CONSTRAINT fk_finished_events_college FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fk_finished_events_location FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL,
  CONSTRAINT fk_finished_events_department FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL
);

-- Finished Event Images

CREATE TABLE public.finished_event_images (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  finished_event_id bigint NOT NULL,
  image_url character varying NOT NULL,

  CONSTRAINT finished_event_images_pkey PRIMARY KEY (id),
  CONSTRAINT fk_finished_event_images_finished_event FOREIGN KEY (finished_event_id) REFERENCES public.finished_events(id) ON DELETE CASCADE
);

-- Finished Event Winners

CREATE TABLE public.finished_event_winners (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  finished_event_id bigint NOT NULL,
  winner_name character varying NOT NULL,
  registration_id bigint,
  prize text,
 
  CONSTRAINT finished_event_winners_pkey PRIMARY KEY (id),
  CONSTRAINT fk_finished_event_winners_finished_event FOREIGN KEY (finished_event_id) REFERENCES public.finished_events(id) ON DELETE CASCADE,
  CONSTRAINT fk_finished_event_winners_registration FOREIGN KEY (registration_id) REFERENCES public.event_registrations(id) ON DELETE SET NULL
);


-- College Newspaper Domain

-- News Papers

CREATE TABLE public.news_papers (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  college_id bigint NOT NULL,
  journalist_id bigint NOT NULL,
  title character varying NOT NULL,
  content text NOT NULL,
  cover_image text NOT NULL,
  state int NOT NULL DEFAULT 0,
  
  created_at timestamp without time zone NOT NULL,
  accepted_by bigint,
  deleted_by bigint,

  CONSTRAINT news_papers_pkey PRIMARY KEY (id),
  CONSTRAINT fkmqjw27p3971exw1jrdvgq1hpi FOREIGN KEY (accepted_by) REFERENCES public.users(id),
  CONSTRAINT fklgc7ll1lrnsjgjerj2lj8rvi FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fk9swsyvxlx6ikm2uxysgsb7h6i FOREIGN KEY (deleted_by) REFERENCES public.college_admins(id),
  CONSTRAINT fkelpelns0qwgvgayl7bc39jt20 FOREIGN KEY (journalist_id) REFERENCES public.journalists(id)
);
-- News Upvotes

CREATE TABLE public.news_upvotes (
  news_id bigint NOT NULL,
  user_id bigint NOT NULL,

  CONSTRAINT news_upvotes_pkey PRIMARY KEY (news_id, user_id),
  CONSTRAINT fksq432dcftiis1p3fff3g64sjy FOREIGN KEY (news_id) REFERENCES public.news_papers(id),
  CONSTRAINT fkhcf4jrgysx3vsogunbgsjm0u6 FOREIGN KEY (user_id) REFERENCES public.users(id)
);


-- College Research Paper Domain

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
  state int NOT NULL DEFAULT 0;
  deleted_by bigint,

  CONSTRAINT research_papers_pkey PRIMARY KEY (id),
  CONSTRAINT fk6yissys8tuarw25fcq7g6j2in FOREIGN KEY (college_id) REFERENCES public.colleges(id),
  CONSTRAINT fkqqp92omf0eqq04rbuv4gjcysa FOREIGN KEY (deleted_by) REFERENCES public.college_admins(id),
  CONSTRAINT fki2jbw9jqompn3o5kwlio8lll FOREIGN KEY (professor_id) REFERENCES public.professors(id),
  CONSTRAINT fk7fdf00altn32qk1o8l86nq5c2 FOREIGN KEY (student_id) REFERENCES public.students(id)
);
-- Research Papers Upvotes

CREATE TABLE public.research_papers_upvotes (
  research_id bigint NOT NULL,
  user_id bigint NOT NULL,

  CONSTRAINT research_papers_upvotes_pkey PRIMARY KEY (research_id, user_id),
  CONSTRAINT fk_research_papers_upvotes_research_paper FOREIGN KEY (research_id) REFERENCES public.research_papers(id) ON DELETE CASCADE,
  CONSTRAINT fk_research_papers_upvotes_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);


-- Global Domain

-- System Admins

CREATE TABLE public.system_admins (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  email character varying NOT NULL UNIQUE,
  full_name character varying NOT NULL,
  password character varying NOT NULL,

  CONSTRAINT system_admins_pkey PRIMARY KEY (id)
);


-- Global Events Domain

-- Global Events

CREATE TABLE public.global_events (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  location_id bigint,
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

  CONSTRAINT global_events_pkey PRIMARY KEY (id),
  CONSTRAINT fk_global_events_created_by FOREIGN KEY (created_by) REFERENCES public.system_admins(id),
  CONSTRAINT fk_global_events_deleted_by FOREIGN KEY (deleted_by) REFERENCES public.users(id),
  CONSTRAINT fk_global_events_location FOREIGN KEY (location_id) REFERENCES public.locations(id)
);

-- Global Event Registration Plans

CREATE TABLE public.global_event_registration_plans (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  global_event_id bigint NOT NULL,
  name character varying NOT NULL,
  description character varying,
  price numeric NOT NULL,
  max_seats integer,

  CONSTRAINT global_event_registration_plans_pkey PRIMARY KEY (id),
  CONSTRAINT fk_global_event_registration_plans_event FOREIGN KEY (global_event_id) REFERENCES public.global_events(id) ON DELETE CASCADE
);

-- Global Event Registrations

CREATE TABLE public.global_event_registrations (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  global_event_id bigint NOT NULL,
  user_id bigint NOT NULL,
  registration_plan_id bigint,
  registration_data jsonb,
  registered_at timestamp without time zone NOT NULL,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['REGISTERED'::character varying, 'CANCELLED'::character varying, 'PAYMENT_PENDING'::character varying, 'PAYMENT_COMPLETED'::character varying]::text[])),

  CONSTRAINT global_event_registrations_pkey PRIMARY KEY (id),
  CONSTRAINT fk_global_event_registrations_plan FOREIGN KEY (registration_plan_id) REFERENCES public.global_event_registration_plans(id),
  CONSTRAINT fk_global_event_registrations_user FOREIGN KEY (user_id) REFERENCES public.users(id),
  CONSTRAINT fk_global_event_registrations_event FOREIGN KEY (global_event_id) REFERENCES public.global_events(id) ON DELETE CASCADE
);

-- Global Event Announcements

CREATE TABLE public.global_event_announcements (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  global_event_id bigint NOT NULL,
  created_by bigint NOT NULL,
  deleted_by bigint,
  title character varying NOT NULL,
  content text,
  image_url text,
  status character varying NOT NULL CHECK (status::text = ANY (ARRAY['UPCOMING'::character varying, 'LIVE'::character varying]::text[])),
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT global_event_announcements_pkey PRIMARY KEY (id),
  CONSTRAINT fk_global_event_announcements_event FOREIGN KEY (global_event_id) REFERENCES public.global_events(id) ON DELETE CASCADE,
  CONSTRAINT fk_global_event_announcements_created_by FOREIGN KEY (created_by) REFERENCES public.system_admins(id),
  CONSTRAINT fk_global_event_announcements_deleted_by FOREIGN KEY (deleted_by) REFERENCES public.users(id)
);

-- Global Finished Events

CREATE TABLE public.finished_global_events (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  title character varying NOT NULL,
  event_type character varying NOT NULL CHECK (event_type::text = ANY (ARRAY['OFFLINE'::character varying, 'ONLINE'::character varying]::text[])),
  location_id bigint,
  start_time timestamp without time zone NOT NULL,
  end_time timestamp without time zone NOT NULL,
  cover_image character varying,
  overview text,
  event_details text NOT NULL, -- Markdown formatted string containing announcements, sponsors, speakers, etc.
  college_details text, -- Text format details about the colleges involved
  created_at timestamp without time zone NOT NULL,

  CONSTRAINT finished_global_events_pkey PRIMARY KEY (id),
  CONSTRAINT fk_finished_global_events_location FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL
);

-- Global Finished Event Images

CREATE TABLE public.finished_global_event_images (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  finished_global_event_id bigint NOT NULL,
  image_url character varying NOT NULL,

  CONSTRAINT finished_global_event_images_pkey PRIMARY KEY (id),
  CONSTRAINT fk_finished_global_event_images_event FOREIGN KEY (finished_global_event_id) REFERENCES public.finished_global_events(id) ON DELETE CASCADE
);

-- Global Finished Event Winners

CREATE TABLE public.finished_global_event_winners (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  finished_global_event_id bigint NOT NULL,
  winner_name character varying NOT NULL,
  registration_id bigint,
  prize text,

  CONSTRAINT finished_global_event_winners_pkey PRIMARY KEY (id),
  CONSTRAINT fk_finished_global_event_winners_event FOREIGN KEY (finished_global_event_id) REFERENCES public.finished_global_events(id) ON DELETE CASCADE,
  CONSTRAINT fk_finished_global_event_winners_registration FOREIGN KEY (registration_id) REFERENCES public.global_event_registrations(id) ON DELETE SET NULL
);


-- Global Newspapers Domain

-- Global News Papers

CREATE TABLE public.global_news_papers (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  news_paper_id bigint NOT NULL UNIQUE,

  published_at timestamp without time zone NOT NULL,
  published_by bigint NOT NULL,

  CONSTRAINT global_news_papers_pkey PRIMARY KEY (id),
  CONSTRAINT fk_global_news_papers_news_paper FOREIGN KEY (news_paper_id) REFERENCES public.news_papers(id) ON DELETE CASCADE,
  CONSTRAINT fk_global_news_papers_published_by FOREIGN KEY (published_by) REFERENCES public.college_admins(id)
);

-- Global News Upvotes

CREATE TABLE public.global_news_upvotes (
  global_news_id bigint NOT NULL,
  user_id bigint NOT NULL,

  CONSTRAINT global_news_upvotes_pkey PRIMARY KEY (global_news_id, user_id),
  CONSTRAINT fk_global_news_upvotes_global_news FOREIGN KEY (global_news_id) REFERENCES public.global_news_papers(id) ON DELETE CASCADE,
  CONSTRAINT fk_global_news_upvotes_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);


-- Global Research Paper Domain

-- Global Research Papers

CREATE TABLE public.global_research_papers (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  research_paper_id bigint NOT NULL UNIQUE,
  published_at timestamp without time zone NOT NULL,
  published_by bigint NOT NULL,

  CONSTRAINT global_research_papers_pkey PRIMARY KEY (id),
  CONSTRAINT fk_global_research_papers_research_paper FOREIGN KEY (research_paper_id) REFERENCES public.research_papers(id) ON DELETE CASCADE,
  CONSTRAINT fk_global_research_papers_published_by FOREIGN KEY (published_by) REFERENCES public.college_admins(id)
);

-- Global Research Papers Upvotes

CREATE TABLE public.global_research_papers_upvotes (
  global_research_paper_id bigint NOT NULL,
  user_id bigint NOT NULL,

  CONSTRAINT global_research_papers_upvotes_pkey PRIMARY KEY (global_research_paper_id, user_id),
  CONSTRAINT fk_global_research_papers_upvotes_paper FOREIGN KEY (global_research_paper_id) REFERENCES public.global_research_papers(id) ON DELETE CASCADE,
  CONSTRAINT fk_global_research_papers_upvotes_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);