create schema http;

create table http.status_codes(
    xr uuid primary key default gen_random_uuid(),
    code int primary key,
    reason text not null
);
insert into http.status_codes(code, reason) VALUES
(100, 'CONTINUE'),
(101, 'SWITCHING PROTOCOLS'),
(102, 'PROCESSING'),
(103, 'EARLY HINTS'),

(200, 'OK'),
(201, 'CREATED'),
(202, 'ACCEPTED'),
(203, 'NON AUTHORITATIVE INFORMATION'),
(204, 'NO CONTENT'),
(205, 'RESET CONTENT'),
(206, 'PARTIAL CONTENT'),
(207, 'MULTI STATUS'),
(208, 'ALREADY REPORTED'),
(226, 'IM USED'),

(300, 'MULTIPLE CHOICES'),
(301, 'MOVED PERMANENTLY'),
(302, 'FOUND'),
(303, 'SEE OTHER'),
(304, 'NOT MODIFIED'),
(307, 'TEMPORARY REDIRECT'),
(308, 'PERMANENT REDIRECT'),

(400, 'BAD REQUEST'),
(401, 'UNAUTHORIZED'),
(403, 'FORBIDDEN'),
(404, 'NOT FOUND'),
(405, 'METHOD NOT ALLOWED'),
(406, 'NOT ACCEPTABLE'),
(407, 'PROXY AUTHENTICATION REQUIRED'),
(408, 'REQUEST TIMEOUT'),
(409, 'CONFLICT'),
(410, 'GONE'),
(411, 'LENGTH REQUIRED'),
(412, 'PRECONDITION FAILED'),
(413, 'PAYLOAD TOO LARGE'),
(414, 'URI TOO LONG'),
(415, 'UNSUPPORTED MEDIA TYPE'),
(416, 'REQUESTED RANGE NOT SATISFIABLE'),
(417, 'EXPECTATION FAILED'),
(418, 'I AM A TEAPOT'),
(421, 'MISDIRECTED REQUEST'),
(422, 'UNPROCESSABLE ENTITY'),
(423, 'LOCKED'),
(424, 'FAILED DEPENDENCY'),
(425, 'TOO EARLY'),
(426, 'UPGRADE REQUIRED'),
(428, 'PRECONDITION REQUIRED'),
(429, 'TOO MANY REQUESTS'),
(431, 'REQUEST HEADER FIELDS TOO LARGE'),
(451, 'UNAVAILABLE FOR LEGAL REASONS'),

(500, 'INTERNAL SERVER ERROR'),
(501, 'NOT IMPLEMENTED'),
(502, 'BAD GATEWAY'),
(503, 'SERVICE UNAVAILABLE'),
(504, 'GATEWAY TIMEOUT'),
(505, 'HTTP VERSION NOT SUPPORTED'),
(506, 'VARIANT ALSO NEGOTIATES'),
(507, 'INSUFFICIENT STORAGE'),
(508, 'LOOP DETECTED'),
(510, 'NOT EXTENDED'),
(511, 'NETWORK AUTHENTICATION REQUIRED');


create type http.request_t as (method text, uri text, version text, headers text[], body text);
create function http.request as (method text, uri text, version text, headers text[], body text)
returns http.request_t
language sql
as $$
    select
        method,
        uri,
        version,
        headers,
        body
$$;

create type http.response_t as (version text, status int, reason text, headers text[], body text);
create function http.response as (version text, status int, reason text, headers text[], body text)
returns http.response_t
language sql
as $$
    select
        COALESCE(version, 'HTTP/1.1'),
        status,
        COALESCE(
            reason,
            (SELECT reason FROM http.status_codes WHERE code = status),
            ''
        ),
        ARRAY[
            'Content-Length: ' || length(body)
        ] || headers,
        body
$$;

create function http.jsonb_response as (version text, status int, reason text, headers text[], body jsonb)
returns http.response_t
language sql
as $$
    select http.response(
        version -> version,
        status -> status,
        reason -> reason,
        headers -> ARRAY[
            'Content-Type: application/json'
        ] || headers,
        body -> body::text
    )
$$;


create table http.routes (
    id UUID primary key default gen_random_uuid(),
    method text not null,
    path text not null,
    handler text not null
);

create function http.handle(p_request http.request_t)
returns http_response
language plpgsql
as $$
declare
    l_handler text;
begin
    l_handler := (
        SELECT handler
        FROM http.routes
        WHERE 1=1
            AND (1=0
                OR (http.routes.method = p_request.method)
                OR (http.routes.method = '*')
            )
            AND (http.routes.path ~ p_request.uri)
    )

    return execute('SELECT ' || l_handler || '($1)', p_request);
end;
$$;
    
