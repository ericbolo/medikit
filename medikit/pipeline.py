import datetime
import json


class Pipeline:
    def __init__(self):
        self.steps = []

    def add(self, step):
        self.steps.append(step)
        return self


def get_identity(step):
    return str(step)


class ConfiguredPipeline:
    def __init__(self, name, pipeline):
        self.name = name
        self.steps = pipeline.steps
        self.meta = {'created': str(datetime.datetime.now())}

    def init(self):
        for step in self.steps:
            step.init()

    def next(self):
        for step in self.steps:
            if not step.complete:
                return step
        raise StopIteration('No step left.')

    def abort(self):
        for step in self.steps:
            step.abort()

    def serialize(self):
        return json.dumps({
            'meta': {
                **self.meta,
                'updated': str(datetime.datetime.now()),
            },
            'steps': [
                [get_identity(step), step.get_state()]
                for step in self.steps
            ]
        })

    def unserialize(self, serialized):
        serialized = json.loads(serialized)
        self.meta = serialized.get('meta', {})
        steps = serialized.get('steps', [])
        if len(steps) != len(self.steps):
            raise IOError('Invalid pipeline state storage.')
        for (identity, state), step in zip(steps, self.steps):
            if get_identity(step) != identity:
                raise IOError('Mismatch on step identity.')
            step.set_state(state)