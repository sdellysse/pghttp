import http from "node:http";
import postgres from "postgres";

const pg = postgres();
const httpApp = http.createServer(async (req, res) => {
  let body = "";
  req.on("readable", () => (body = `${body}${req.read()}`));

  const httpVersion = `HTTP/${req.httpVersion}`;
  const method = req.method ?? "";
  const url = req.url ?? "";
  const headers: Array<string> = [];
  for (let i = 0; i < req.rawHeaders.length; i += 2) {
    headers.push(`${req.rawHeaders[i]}: ${req.rawHeaders[i + 1]}`);
  }

  await new Promise((resolve) => req.on("end", resolve));

  const rows = await pg`
    SELECT http.handle(http.request(
      version -> ${httpVersion},
      method -> ${method},
      url -> ${url},
      headers -> ${headers},
      body -> ${body}
    )) AS http
  `;

  if (rows.length === 0) {
    console.error("No rows returned from database");
    process.exit(1);
  }
  if (rows.length > 1) {
    console.error("More than one row returned from database");
    process.exit(1);
  }
  const row = rows[0]!;

  await new Promise<void>((resolve) =>
    res.end(
      Buffer.from(
        [
          `HTTP/${row.http.version} ${row.http.status} ${row.http.reason}`,
          ...row.http.headers,
          "",
          row.http.body,
        ].join("\r\n")
      ),
      resolve
    )
  );
});

httpApp.listen(process.env.PORT ?? 80);
