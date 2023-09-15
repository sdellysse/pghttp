INSERT INTO http.routes(method, uri, handler) VALUES('POST', E'/api/sign-up', 'httroutes.post_api__sign_up');
create function httroutes.post_api__sign_up(request http.request_t)
returns http.response_t
language plpgsql
as $$
declare
    l_token text;
begin
    l_token := (
        WITH cte_user AS (
            INSERT INTO a.users (xr, email, password)
            VALUES (gen_random_uuid(), request.body->>'email', CRYPT(request.body->>'password', GEN_SALT('bf')))
            RETURNING xr
        )

        INSERT INTO a.session(xr, user_xr, token)
        VALUES(gen_random_uuid(), (SELECT xr FROM cte_user), gen_random_uuid())
        RETURNING token
    );

    return http.jsonb_response(
        status => 201,
        body => JSONB_BUILD_OBJECT(
            'token', l_token
        )
    )
    
    return l_response;
end;
$$;
