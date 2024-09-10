#!/usr/bin/env python3
import uuid
import json


print(json.dumps({"id": str(uuid.uuid4())}))
