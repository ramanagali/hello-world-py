from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def hello_world():
    # Pretty-print JSON with an indent of 4 spaces
    return jsonify(message="When in doubt, fish!"), 200, {"Content-Type": "application/json; charset=utf-8"}

if __name__ == '__main__':
    app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True
    app.run(host='0.0.0.0', port=4000)
